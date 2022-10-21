// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainNamespace
import Combine
import DIKit
import Errors
import FeatureOpenBankingDomain
import FeaturePlaidDomain
import MoneyKit
import PlatformKit
import RxSwift
import ToolKit

extension OrderDetails: TransactionOrder {}

final class BuyTransactionEngine: TransactionEngine {

    var sourceAccount: BlockchainAccount!
    var transactionTarget: TransactionTarget!
    let canTransactFiat: Bool = true

    // Used to convert fiat <-> crypto when user types an amount (mainly crypto -> fiat)
    let currencyConversionService: CurrencyConversionServiceAPI
    // Used to convert payment method currencies into the wallet's trading currency
    let walletCurrencyService: FiatCurrencyServiceAPI

    private let app: AppProtocol
    // Used to convert the user input into an actual quote with fee (takes a fiat amount)
    private let orderQuoteService: OrderQuoteServiceAPI
    // Used to create a pending order when the user confirms the transaction
    private let orderCreationService: OrderCreationServiceAPI
    // Used to execute the order once created
    private let orderConfirmationService: OrderConfirmationServiceAPI
    // Used to cancel orders
    private let orderCancellationService: OrderCancellationServiceAPI
    // Used to fetch limits for the transaction
    private let transactionLimitsService: TransactionLimitsServiceAPI
    // Used to fetch the user KYC status and adjust limits for Tier 0 and Tier 1 users to let them enter a transaction irrespective of limits
    private let kycTiersService: KYCTiersServiceAPI
    // Used to fetch account statuses via settlement API
    private let plaidRepository: PlaidRepositoryAPI

    init(
        app: AppProtocol = resolve(),
        currencyConversionService: CurrencyConversionServiceAPI = resolve(),
        walletCurrencyService: FiatCurrencyServiceAPI = resolve(),
        orderQuoteService: OrderQuoteServiceAPI = resolve(),
        orderCreationService: OrderCreationServiceAPI = resolve(),
        orderConfirmationService: OrderConfirmationServiceAPI = resolve(),
        orderCancellationService: OrderCancellationServiceAPI = resolve(),
        transactionLimitsService: TransactionLimitsServiceAPI = resolve(),
        kycTiersService: KYCTiersServiceAPI = resolve(),
        plaidRepository: PlaidRepositoryAPI = resolve()
    ) {
        self.app = app
        self.currencyConversionService = currencyConversionService
        self.walletCurrencyService = walletCurrencyService
        self.orderQuoteService = orderQuoteService
        self.orderCreationService = orderCreationService
        self.orderConfirmationService = orderConfirmationService
        self.orderCancellationService = orderCancellationService
        self.transactionLimitsService = transactionLimitsService
        self.kycTiersService = kycTiersService
        self.plaidRepository = plaidRepository
    }

    var fiatExchangeRatePairs: Observable<TransactionMoneyValuePairs> {
        transactionExchangeRatePair
            .map { quote in
                TransactionMoneyValuePairs(
                    source: quote,
                    destination: quote.inverseExchangeRate
                )
            }
    }

    var fiatExchangeRatePairsSingle: Single<TransactionMoneyValuePairs> {
        fiatExchangeRatePairs
            .take(1)
            .asSingle()
    }

    var transactionExchangeRatePair: Observable<MoneyValuePair> {
        let cryptoCurrency = transactionTarget.currencyType
        return walletCurrencyService
            .tradingCurrencyPublisher
            .map(\.currencyType)
            .flatMap { [currencyConversionService] tradingCurrency in
                currencyConversionService
                    .conversionRate(from: cryptoCurrency, to: tradingCurrency)
                    .map { quote in
                        MoneyValuePair(
                            base: .one(currency: cryptoCurrency),
                            quote: quote
                        )
                    }
            }
            .asObservable()
            .share(replay: 1, scope: .whileConnected)
    }

    // Unused but required by `TransactionEngine` protocol
    var askForRefreshConfirmation: AskForRefreshConfirmation!

    func assertInputsValid() {
        assert(sourceAccount is PaymentMethodAccount)
        assert(transactionTarget is CryptoAccount)
    }

    func initializeTransaction() -> Single<PendingTransaction> {
        makeTransaction()
    }

    func update(amount: MoneyValue, pendingTransaction: PendingTransaction) -> Single<PendingTransaction> {
        makeTransaction(amount: amount)
    }

    func validateAmount(
        pendingTransaction: PendingTransaction
    ) -> Single<PendingTransaction> {
        defaultValidateAmount(pendingTransaction: pendingTransaction)
            .flatMap(weak: self) { (self, pendingTransaction) in
                self.validateIfSourceAccountIsBlocked(pendingTransaction)
            }
            .observe(on: MainScheduler.asyncInstance)
    }

    private func validateSourceBankAccountStatus(
        pendingTransaction: PendingTransaction
    ) -> Single<PendingTransaction> {
        guard let sourceAccount = sourceAccount as? PaymentMethodAccount else {
            return .error(TransactionValidationFailure(state: .optionInvalid))
        }
        guard app.state.yes(if: blockchain.ux.payment.method.plaid.is.available) else {
            return .just(pendingTransaction)
        }
        let accountId: String = sourceAccount.paymentMethodType.id
        return plaidRepository
            .getSettlementInfo(
                accountId: accountId,
                amount: pendingTransaction.amount.minorString
            )
            .asSingle()
            .flatMap { info in
                if let ux = info.error {
                    return .error(UX.Error(nabu: ux))
                }
                if let ux = info.settlement.reason?.uxError(accountId) {
                    return .error(ux)
                }
                return .just(pendingTransaction)
            }
    }

    func doValidateAll(pendingTransaction: PendingTransaction) -> Single<PendingTransaction> {
        validateIfSourceAccountIsBlocked(pendingTransaction)
            .flatMap(weak: self) { (self, pendingTransaction) in
                self.validateSourceBankAccountStatus(pendingTransaction: pendingTransaction)
            }
            .flatMap(weak: self) { (self, pendingTransaction) in
                self.validateAmount(pendingTransaction: pendingTransaction)
            }
            .updateTxValiditySingle(pendingTransaction: pendingTransaction)
            .observe(on: MainScheduler.asyncInstance)
    }

    func doBuildConfirmations(pendingTransaction: PendingTransaction) -> Single<PendingTransaction> {
        let sourceAccountLabel = sourceAccount.label
        if app.remoteConfiguration.yes(if: blockchain.ux.transaction.checkout.quote.refresh.is.enabled) {
            return .just(pendingTransaction)
        }
        return createOrder(pendingTransaction: pendingTransaction)
            .map { order -> OrderDetails in
                guard let order = order as? OrderDetails else {
                    impossible("Buy transactions should only create \(OrderDetails.self) orders")
                }
                return order
            }
            .map { order -> PendingTransaction in
                let fiatAmount = order.inputValue
                let cryptoAmount = order.outputValue
                let exchangeRate = MoneyValuePair(base: cryptoAmount, quote: fiatAmount).exchangeRate

                let totalCost = order.inputValue
                let fee = order.fee ?? .zero(currency: fiatAmount.currency)
                let purchase = try totalCost - fee

                var confirmations: [TransactionConfirmation] = [
                    TransactionConfirmations.BuyCryptoValue(baseValue: cryptoAmount),
                    TransactionConfirmations.BuyExchangeRateValue(
                        baseValue: exchangeRate.quote,
                        code: exchangeRate.base.code
                    ),
                    TransactionConfirmations.Purchase(purchase: purchase),
                    TransactionConfirmations.FiatTransactionFee(fee: fee)
                ]

                if let customFeeAmount = pendingTransaction.customFeeAmount {
                    confirmations.append(TransactionConfirmations.FiatTransactionFee(fee: customFeeAmount))
                }

                confirmations += [
                    TransactionConfirmations.Total(total: totalCost),
                    TransactionConfirmations.BuyPaymentMethodValue(name: sourceAccountLabel)
                ]

                return pendingTransaction.update(confirmations: confirmations)
            }
    }

    func createOrder(pendingTransaction: PendingTransaction) -> Single<TransactionOrder?> {
        if app.remoteConfiguration.yes(if: blockchain.ux.transaction.checkout.quote.refresh.is.enabled), let quote = pendingTransaction.quote {
            return createOrder(quote: quote)
        } else {
            return fetchQuote(for: pendingTransaction.amount)
                .filter(\.quoteId.isNotNilOrEmpty)
                .timeout(.seconds(5), scheduler: MainScheduler.asyncInstance)
                .flatMap(weak: self) { (self, quote) in
                    self.createOrder(
                        quote: .init(id: quote.quoteId!, amount: quote.estimatedSourceAmount)
                    )
                }
        }
    }

    func createOrder(quote: PendingTransaction.Quote) -> Single<TransactionOrder?> {
        guard let sourceAccount = sourceAccount as? PaymentMethodAccount else {
            return .error(TransactionValidationFailure(state: .optionInvalid))
        }
        guard let destinationAccount = transactionTarget as? CryptoTradingAccount, let crypto = destinationAccount.currencyType.cryptoCurrency else {
            return .error(TransactionValidationFailure(state: .optionInvalid))
        }
        guard let fiatValue = quote.amount.fiatValue else {
            return .error(TransactionValidationFailure(state: .incorrectSourceCurrency))
        }
        let paymentMethodId: String?
        if sourceAccount.paymentMethod.type.isFunds || sourceAccount.paymentMethod.type.isApplePay {
            paymentMethodId = nil
        } else {
            paymentMethodId = sourceAccount.paymentMethodType.id
        }
        let orderDetails = CandidateOrderDetails.buy(
            quoteId: quote.id,
            paymentMethod: sourceAccount.paymentMethodType,
            fiatValue: fiatValue,
            cryptoValue: .zero(currency: crypto),
            paymentMethodId: paymentMethodId
        )
        return orderCreationService.create(using: orderDetails)
            .do(
                onSuccess: { checkoutData in
                    Logger.shared.info("[BUY] Order creation successful \(String(describing: checkoutData))")
                },
                onError: { error in
                    Logger.shared.error("[BUY] Order creation failed \(String(describing: error))")
                }
            )
            .map(\.order)
            .map(Optional.some)
    }

    func cancelOrder(with identifier: String) -> Single<Void> {
        orderCancellationService.cancelOrder(with: identifier)
            .asSingle()
    }

    func execute(
        pendingTransaction: PendingTransaction,
        pendingOrder: TransactionOrder?
    ) -> Single<TransactionResult> {

        func execute(_ order: OrderDetails) -> Single<TransactionResult> {
            // Execute the order
            orderConfirmationService.confirm(checkoutData: CheckoutData(order: order))
                .asSingle()
            // Map order to Transaction Result
                .map { checkoutData -> TransactionResult in
                    TransactionResult.unHashed(
                        amount: pendingTransaction.amount,
                        orderId: checkoutData.order.identifier,
                        order: checkoutData.order
                    )
                }
                .do(onSuccess: { checkoutData in
                    Logger.shared.info("[BUY] Order confirmation successful \(String(describing: checkoutData))")
                }, onError: { error in
                    Logger.shared.error("[BUY] Order confirmation failed \(String(describing: error))")
                })
        }

        if let order = pendingOrder as? OrderDetails {
            if let error = order.error {
                return .error(OpenBanking.Error.code(error))
            }
            return execute(order)
        } else {
            return createOrder(pendingTransaction: pendingTransaction)
                .flatMap { order in execute(order as! OrderDetails) }
        }
    }

    func doUpdateFeeLevel(
        pendingTransaction: PendingTransaction,
        level: FeeLevel,
        customFeeAmount: MoneyValue
    ) -> Single<PendingTransaction> {
        impossible("Fees are fixed for buying crypto")
    }
}

// MARK: - Helpers

extension BuyTransactionEngine {

    enum MakeTransactionError: Error {
        case priceError(PriceServiceError)
        case nabuError(Nabu.Error)
        case limitsError(TransactionLimitsServiceError)
    }

    private var isCardSuccessRateEnabled: AnyPublisher<Bool, Never> {
        let event: Tag.Event = blockchain.app.configuration.card.success.rate.is.enabled
        return app.publisher(for: event, as: Bool.self)
            .prefix(1)
            .replaceError(with: false)
    }

    private func validateIfSourceAccountIsBlocked(
        _ pendingTransaction: PendingTransaction
    ) -> Single<PendingTransaction> {
        isCardSuccessRateEnabled
            .asSingle()
            .flatMap { [sourceAccount] isEnabled -> Single<PendingTransaction> in
                guard let sourceAccount = sourceAccount as? PaymentMethodAccount else {
                    return .error(TransactionValidationFailure(state: .optionInvalid))
                }
                guard isEnabled else { return .just(pendingTransaction) }
                if let ux = sourceAccount.paymentMethodType.ux {
                    guard !sourceAccount.paymentMethodType.block else {
                        return .just(
                            pendingTransaction
                                .update(
                                    validationState: .sourceAccountUsageIsBlocked(ux)
                                )
                        )
                    }
                }
                return .just(pendingTransaction)
            }
    }

    private func makeTransaction(amount: MoneyValue? = nil) -> Single<PendingTransaction> {
        guard let sourceAccount = sourceAccount as? PaymentMethodAccount else {
            return .error(TransactionValidationFailure(state: .optionInvalid))
        }
        let paymentMethod = sourceAccount.paymentMethod
        let amount = amount ?? .zero(currency: paymentMethod.fiatCurrency.currencyType)
        return Publishers.Zip(
            convertSourceBalance(to: amount.currencyType),
            transactionLimits(for: paymentMethod, inputCurrency: amount.currencyType)
        )
        .tryMap { sourceBalance, limits in
            // NOTE: the fee coming from the API is always 0 at the moment.
            // The correct fee will be fetched when the order is created.
            // This misleading behavior doesn't affect the purchase.
            // That said, this is going to be fixed once we migrate to v2 of the quotes API.
            let zeroFee: MoneyValue = .zero(currency: amount.currency)
            return PendingTransaction(
                amount: amount,
                available: sourceBalance,
                feeAmount: zeroFee,
                feeForFullAvailable: zeroFee,
                feeSelection: .empty(asset: amount.currencyType),
                selectedFiatCurrency: sourceAccount.fiatCurrency,
                limits: limits
            )
        }
        .asSingle()
        .flatMap { pendingTransaction in
            self.validateIfSourceAccountIsBlocked(pendingTransaction)
        }
        .observe(on: MainScheduler.asyncInstance)
    }

    private func fetchQuote(for amount: MoneyValue) -> Single<Quote> {
        guard let source = sourceAccount as? FiatAccount else {
            return .error(TransactionValidationFailure(state: .uninitialized))
        }
        guard let destination = transactionTarget as? CryptoAccount else {
            return .error(TransactionValidationFailure(state: .uninitialized))
        }
        let paymentMethod = (sourceAccount as? PaymentMethodAccount)?.paymentMethodType.method
        let paymentMethodId = (sourceAccount as? PaymentMethodAccount)?.paymentMethodType.id
        return convertAmountIntoTradingCurrency(amount)
            .flatMap { [orderQuoteService] fiatValue in
                orderQuoteService.getQuote(
                    query: QuoteQuery(
                        profile: .simpleBuy,
                        sourceCurrency: source.fiatCurrency,
                        destinationCurrency: destination.asset,
                        amount: MoneyValue(fiatValue: fiatValue),
                        paymentMethod: paymentMethod?.requestType,
                        // the endpoint only accepts paymentMethodId parameter if paymentMethod is bank transfer
                        // refactor this by gracefully handle at the model level
                        paymentMethodId: (paymentMethod?.isBankTransfer ?? false) ? paymentMethodId : nil
                    )
                )
            }
    }

    private func convertAmountIntoTradingCurrency(_ amount: MoneyValue) -> Single<FiatValue> {
        fiatExchangeRatePairsSingle
            .map { moneyPair in
                guard !amount.isFiat else {
                    return amount.fiatValue!
                }
                return try amount
                    .convert(using: moneyPair.source)
                    .fiatValue!
            }
    }

    private func convertSourceBalance(to currency: CurrencyType) -> AnyPublisher<MoneyValue, MakeTransactionError> {
        sourceAccount
            .balance
            .replaceError(with: .zero(currency: currency))
            .flatMap { [currencyConversionService] balance in
                currencyConversionService.convert(balance, to: currency)
            }
            .mapError(MakeTransactionError.priceError)
            .eraseToAnyPublisher()
    }

    private func transactionLimits(
        for paymentMethod: PaymentMethod,
        inputCurrency: CurrencyType
    ) -> AnyPublisher<TransactionLimits, MakeTransactionError> {
        let targetCurrency = transactionTarget.currencyType
        return kycTiersService.canPurchaseCrypto
            .setFailureType(to: MakeTransactionError.self)
            .flatMap { [transactionLimitsService] canPurchaseCrypto -> AnyPublisher<TransactionLimits, MakeTransactionError> in
                // if the user cannot purchase crypto, still just use the limits from the payment method to let them move on with the transaction
                // this way, the logic of checking email verification and KYC status will kick-in when they attempt to navigate to the checkout screen.
                guard canPurchaseCrypto else {
                    return .just(TransactionLimits(paymentMethod))
                }
                return transactionLimitsService
                    .fetchLimits(
                        for: paymentMethod,
                        targetCurrency: targetCurrency,
                        limitsCurrency: inputCurrency,
                        product: .simplebuy
                    )
                    .mapError(MakeTransactionError.limitsError)
                    .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }
}
