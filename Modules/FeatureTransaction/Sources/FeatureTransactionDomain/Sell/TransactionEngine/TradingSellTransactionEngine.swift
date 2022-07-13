// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BigInt
import Combine
import DIKit
import FeatureProductsDomain
import MoneyKit
import NetworkKit
import PlatformKit
import RxSwift
import ToolKit

final class TradingSellTransactionEngine: SellTransactionEngine {

    let canTransactFiat: Bool = true
    var requireSecondPassword: Bool = false
    let quotesEngine: QuotesEngineAPI
    let walletCurrencyService: FiatCurrencyServiceAPI
    let currencyConversionService: CurrencyConversionServiceAPI
    let transactionLimitsService: TransactionLimitsServiceAPI
    let orderQuoteRepository: OrderQuoteRepositoryAPI
    let orderCreationRepository: OrderCreationRepositoryAPI
    let orderDirection: OrderDirection = .internal
    // Used to check product eligibility
    private let productsService: FeatureProductsDomain.ProductsServiceAPI

    private var actionableBalance: Single<MoneyValue> {
        sourceAccount.actionableBalance.asSingle()
    }

    init(
        quotesEngine: QuotesEngineAPI = resolve(),
        walletCurrencyService: FiatCurrencyServiceAPI = resolve(),
        currencyConversionService: CurrencyConversionServiceAPI = resolve(),
        transactionLimitsService: TransactionLimitsServiceAPI = resolve(),
        orderQuoteRepository: OrderQuoteRepositoryAPI = resolve(),
        orderCreationRepository: OrderCreationRepositoryAPI = resolve(),
        productsService: FeatureProductsDomain.ProductsServiceAPI = resolve()
    ) {
        self.quotesEngine = quotesEngine
        self.walletCurrencyService = walletCurrencyService
        self.currencyConversionService = currencyConversionService
        self.transactionLimitsService = transactionLimitsService
        self.orderQuoteRepository = orderQuoteRepository
        self.orderCreationRepository = orderCreationRepository
        self.productsService = productsService
    }

    // MARK: - Transaction Engine

    var askForRefreshConfirmation: AskForRefreshConfirmation!

    var sourceAccount: BlockchainAccount!
    var transactionTarget: TransactionTarget!

    func assertInputsValid() {
        precondition(sourceAccount is TradingAccount)
        precondition(transactionTarget is FiatAccount)
    }

    var pair: OrderPair {
        OrderPair(
            sourceCurrencyType: sourceAsset.currencyType,
            destinationCurrencyType: target.currencyType
        )
    }

    func initializeTransaction() -> Single<PendingTransaction> {
        quotesEngine
            .startPollingRate(
                direction: orderDirection,
                pair: .init(
                    sourceCurrencyType: sourceAsset,
                    destinationCurrencyType: target.currencyType
                )
            )
        return Single
            .zip(
                quotesEngine.quotePublisher.asSingle(),
                walletCurrencyService.displayCurrency.asSingle(),
                actionableBalance
            )
            .flatMap(weak: self) { (self, payload) -> Single<PendingTransaction> in
                let (pricedQuote, fiatCurrency, actionableBalance) = payload

                let pendingTransaction = PendingTransaction(
                    amount: .zero(currency: self.sourceAsset),
                    available: actionableBalance,
                    feeAmount: .zero(currency: self.sourceAsset),
                    feeForFullAvailable: .zero(currency: self.sourceAsset),
                    feeSelection: .empty(asset: self.sourceAsset),
                    selectedFiatCurrency: fiatCurrency
                )
                return self.updateLimits(
                    pendingTransaction: pendingTransaction,
                    pricedQuote: pricedQuote
                )
                .handlePendingOrdersError(initialValue: pendingTransaction)
            }
    }

    func execute(pendingTransaction: PendingTransaction, secondPassword: String) -> Single<TransactionResult> {
        createOrder(pendingTransaction: pendingTransaction)
            .map { order in
                TransactionResult.unHashed(amount: pendingTransaction.amount, orderId: order.identifier)
            }
    }

    func doUpdateFeeLevel(
        pendingTransaction: PendingTransaction,
        level: FeeLevel,
        customFeeAmount: MoneyValue
    ) -> Single<PendingTransaction> {
        precondition(pendingTransaction.availableFeeLevels.contains(level))
        return Single.just(pendingTransaction)
    }

    func update(amount: MoneyValue, pendingTransaction: PendingTransaction) -> Single<PendingTransaction> {
        Single.zip(
            validateUpdateAmount(amount),
            actionableBalance
        )
        .map { (normalized: MoneyValue, balance: MoneyValue) -> PendingTransaction in
            pendingTransaction.update(amount: normalized, available: balance)
        }
        .do(onSuccess: { [weak self] transaction in
            self?.quotesEngine.update(amount: transaction.amount.amount)
        })
        .map(weak: self) { (self, pendingTransaction) -> PendingTransaction in
            self.clearConfirmations(pendingTransaction: pendingTransaction)
        }
    }

    func doValidateAll(pendingTransaction: PendingTransaction) -> Single<PendingTransaction> {
        validateAmount(pendingTransaction: pendingTransaction)
    }

    func doBuildConfirmations(pendingTransaction: PendingTransaction) -> Single<PendingTransaction> {
        quotesEngine.quotePublisher
            .asSingle()
            .map { [targetAsset] pricedQuote -> (PendingTransaction, PricedQuote) in
                let sellSourceValue = pendingTransaction.amount
                let resultValue = FiatValue(amount: pricedQuote.price, currency: targetAsset).moneyValue
                let baseValue = MoneyValue.one(currency: sellSourceValue.currency)
                let sellDestinationValue: MoneyValue = sellSourceValue.convert(using: resultValue)

                var confirmations: [TransactionConfirmation] = [
                    TransactionConfirmations.QuoteExpirationTimer(
                        expirationDate: pricedQuote.expirationDate
                    )
                ]
                if let sellSourceCryptoValue = sellSourceValue.cryptoValue {
                    confirmations.append(TransactionConfirmations.SellSourceValue(cryptoValue: sellSourceCryptoValue))
                }
                if let sellDestinationFiatValue = sellDestinationValue.fiatValue {
                    confirmations.append(
                        TransactionConfirmations.SellDestinationValue(
                            fiatValue: sellDestinationFiatValue
                        )
                    )
                }
                if !pricedQuote.staticFee.isZero {
                    confirmations.append(TransactionConfirmations.FiatTransactionFee(fee: pricedQuote.staticFee))
                }
                confirmations += [
                    TransactionConfirmations.SellExchangeRateValue(baseValue: baseValue, resultValue: resultValue),
                    TransactionConfirmations.Source(value: self.sourceAccount.label),
                    TransactionConfirmations.Destination(value: self.target.label)
                ]
                let updatedTransaction = pendingTransaction.update(confirmations: confirmations)
                return (updatedTransaction, pricedQuote)
            }
            .flatMap(weak: self) { (self, tuple) in
                let (pendingTransaction, pricedQuote) = tuple
                return self.updateLimits(pendingTransaction: pendingTransaction, pricedQuote: pricedQuote)
            }
    }
}
