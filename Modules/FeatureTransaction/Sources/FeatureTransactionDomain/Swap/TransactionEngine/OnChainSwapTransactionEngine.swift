// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import DIKit
import MoneyKit
import PlatformKit
import RxSwift
import ToolKit

final class OnChainSwapTransactionEngine: SwapTransactionEngine {

    let walletCurrencyService: FiatCurrencyServiceAPI
    let currencyConversionService: CurrencyConversionServiceAPI

    let receiveAddressFactory: ExternalAssetAddressServiceAPI
    let onChainEngine: OnChainTransactionEngine
    let orderCreationRepository: OrderCreationRepositoryAPI
    var orderDirection: OrderDirection {
        target is TradingAccount ? .fromUserKey : .onChain
    }

    let orderQuoteRepository: OrderQuoteRepositoryAPI
    let orderUpdateRepository: OrderUpdateRepositoryAPI
    let quotesEngine: QuotesEngineAPI
    let hotWalletAddressService: HotWalletAddressServiceAPI
    let transactionLimitsService: TransactionLimitsServiceAPI
    var askForRefreshConfirmation: AskForRefreshConfirmation!
    var sourceAccount: BlockchainAccount!
    var transactionTarget: TransactionTarget!

    init(
        onChainEngine: OnChainTransactionEngine,
        quotesEngine: QuotesEngineAPI = resolve(),
        orderQuoteRepository: OrderQuoteRepositoryAPI = resolve(),
        orderCreationRepository: OrderCreationRepositoryAPI = resolve(),
        orderUpdateRepository: OrderUpdateRepositoryAPI = resolve(),
        transactionLimitsService: TransactionLimitsServiceAPI = resolve(),
        walletCurrencyService: FiatCurrencyServiceAPI = resolve(),
        currencyConversionService: CurrencyConversionServiceAPI = resolve(),
        receiveAddressFactory: ExternalAssetAddressServiceAPI = resolve(),
        hotWalletAddressService: HotWalletAddressServiceAPI = resolve()
    ) {
        self.quotesEngine = quotesEngine
        self.orderQuoteRepository = orderQuoteRepository
        self.orderCreationRepository = orderCreationRepository
        self.orderUpdateRepository = orderUpdateRepository
        self.transactionLimitsService = transactionLimitsService
        self.walletCurrencyService = walletCurrencyService
        self.currencyConversionService = currencyConversionService
        self.onChainEngine = onChainEngine
        self.receiveAddressFactory = receiveAddressFactory
        self.hotWalletAddressService = hotWalletAddressService
    }

    func assertInputsValid() {
        // We don't assert anything for On Chain Swap.
    }

    private func startOnChainEngine(pricedQuote: PricedQuote) -> Single<Void> {
        createTransactionTarget(swapOrderDepositAddress: pricedQuote.sampleDepositAddress)
            .flatMap { [onChainEngine, sourceAccount] transactionTarget in
                onChainEngine.start(
                    sourceAccount: sourceAccount!,
                    transactionTarget: transactionTarget,
                    askForRefreshConfirmation: { _ in .empty() }
                )
                return .just(())
            }
    }

    private func defaultFeeLevel(pendingTransaction: PendingTransaction) -> FeeLevel {
        if pendingTransaction.feeSelection.availableLevels.contains(.priority) {
            return .priority
        }
        return pendingTransaction.feeSelection.selectedLevel
    }

    func initializeTransaction() -> Single<PendingTransaction> {
        quotesEngine.startPollingRate(
            direction: orderDirection,
            pair: .init(
                sourceCurrencyType: sourceAsset,
                destinationCurrencyType: target.currencyType
            )
        )
        return quotesEngine.quotePublisher
            .asSingle()
            .flatMap { [weak self] pricedQuote -> Single<PendingTransaction> in
                guard let self else { return .error(ToolKitError.nullReference(Self.self)) }
                return self.startOnChainEngine(pricedQuote: pricedQuote)
                    .flatMap { [weak self] _ -> Single<(FiatCurrency, PendingTransaction)> in
                        guard let self else { return .error(ToolKitError.nullReference(Self.self)) }
                        return Single.zip(
                            self.walletCurrencyService.displayCurrency.asSingle(),
                            self.onChainEngine.initializeTransaction()
                        )
                    }
                    .flatMap { [weak self] fiatCurrency, pendingTransaction -> Single<PendingTransaction> in
                        guard let self else { return .error(ToolKitError.nullReference(Self.self)) }
                        let fallback = PendingTransaction(
                            amount: .zero(currency: self.sourceAsset),
                            available: .zero(currency: self.targetAsset),
                            feeAmount: .zero(currency: self.targetAsset),
                            feeForFullAvailable: .zero(currency: self.sourceAsset),
                            feeSelection: .empty(asset: self.sourceAsset),
                            selectedFiatCurrency: fiatCurrency
                        )
                        return self.updateLimits(
                            pendingTransaction: pendingTransaction,
                            pricedQuote: pricedQuote
                        )
                        .map { [weak self] pendingTx -> PendingTransaction in
                            guard let self else { throw ToolKitError.nullReference(Self.self) }
                            return pendingTx.update(
                                selectedFeeLevel: self.defaultFeeLevel(pendingTransaction: pendingTx)
                            )
                        }
                        .handlePendingOrdersError(initialValue: fallback)
                    }
            }
    }

    func validateAmount(pendingTransaction: PendingTransaction) -> Single<PendingTransaction> {
        onChainEngine
            .validateAmount(pendingTransaction: pendingTransaction)
            .flatMap { [weak self] pendingTransaction -> Single<PendingTransaction> in
                guard let self else { return .error(ToolKitError.nullReference(Self.self)) }
                switch pendingTransaction.validationState {
                case .canExecute:
                    return self.defaultValidateAmount(pendingTransaction: pendingTransaction)
                default:
                    return .just(pendingTransaction)
                }
            }
            .updateTxValiditySingle(pendingTransaction: pendingTransaction)
    }

    func doValidateAll(pendingTransaction: PendingTransaction) -> Single<PendingTransaction> {
        onChainEngine
            .doValidateAll(pendingTransaction: pendingTransaction)
            .flatMap { [weak self] pendingTransaction -> Single<PendingTransaction> in
                guard let self else { return .error(ToolKitError.nullReference(Self.self)) }
                switch pendingTransaction.validationState {
                case .canExecute:
                    return self.defaultDoValidateAll(pendingTransaction: pendingTransaction)
                default:
                    return .just(pendingTransaction)
                }
            }
            .updateTxValiditySingle(pendingTransaction: pendingTransaction)
    }

    func execute(pendingTransaction: PendingTransaction) -> Single<TransactionResult> {
        createOrder(pendingTransaction: pendingTransaction)
            .map { swapOrder -> (identifier: String, depositAddress: String) in
                guard let depositAddress = swapOrder.depositAddress else {
                    throw PlatformKitError.illegalStateException(message: "Missing deposit address")
                }
                return (swapOrder.identifier, depositAddress)
            }
            .flatMap { [weak self] swapOrder -> Single<TransactionResult> in
                guard let self else { return .error(ToolKitError.nullReference(Self.self)) }

                return self.createTransactionTarget(swapOrderDepositAddress: swapOrder.depositAddress)
                    .flatMap { [weak self] transactionTarget -> Single<TransactionResult> in
                        guard let self else { return .error(ToolKitError.nullReference(Self.self)) }
                        return self.executeOnChain(
                            swapOrderIdentifier: swapOrder.identifier,
                            transactionTarget: transactionTarget,
                            pendingTransaction: pendingTransaction
                        )
                    }
            }
    }

    /**
     Creates TransactionTarget for executing the on chain transaction.

     - Returns: Single that emits a TransactionTarget. If there is no hot wallet address for 'swap' associated with the current currency,
     then the emitted value will be the order deposit address. Else, if there is a hot wallet address, it will emit a HotWalletTransactionTarget.

     When sending a transaction to one of Blockchain's custodial products, we check if a hot wallet address for that product
     is available. If that is not available, reference address is null and the transaction happens as it normally would. If it is available,
     we will send the fund directly to the hot wallet address, and pass along the original address (real address) as the
     reference address, that will be added to the transaction data field or as a the third parameter of the overloaded transfer method.
     You can check how this works and the reasons for its implementation here:
     https://www.notion.so/blockchaincom/Up-to-75-cheaper-EVM-wallet-private-key-to-custody-transfers-9675695a02ec49b893af1095ead6cc07
     */

    private func createTransactionTarget(
        swapOrderDepositAddress: String
    ) -> Single<TransactionTarget> {
        let depositAddress = receiveAddressFactory.makeExternalAssetAddress(
            asset: sourceAsset,
            address: swapOrderDepositAddress,
            label: swapOrderDepositAddress,
            onTxCompleted: { _ in .empty() }
        )
        switch depositAddress {
        case .failure(let error):
            return .error(error)
        case .success(let receiveAddress):
            return hotWalletReceiveAddress
                .map { hotWalletAddress -> TransactionTarget in
                    guard let hotWalletAddress else {
                        return receiveAddress
                    }
                    return HotWalletTransactionTarget(
                        realAddress: receiveAddress,
                        hotWalletAddress: hotWalletAddress
                    )
                }
        }
    }

    /// Returns the Hot Wallet receive address for the current cryptocurrency.
    private var hotWalletReceiveAddress: Single<CryptoReceiveAddress?> {
        hotWalletAddressService
            .hotWalletAddress(for: sourceAsset, product: .swap)
            .asSingle()
            .flatMap { [sourceAsset, receiveAddressFactory] hotWalletAddress -> Single<CryptoReceiveAddress?> in
                guard let hotWalletAddress else {
                    return .just(nil)
                }
                return receiveAddressFactory.makeExternalAssetAddress(
                    asset: sourceAsset,
                    address: hotWalletAddress,
                    label: hotWalletAddress,
                    onTxCompleted: { _ in .empty() }
                )
                .single
                .optional()
            }
            .catchAndReturn(nil)
    }

    /// Restart and executes the order in the On Chain Engine
    private func executeOnChain(
        swapOrderIdentifier: String,
        transactionTarget: TransactionTarget,
        pendingTransaction: PendingTransaction
    ) -> Single<TransactionResult> {
        onChainEngine
            .restart(transactionTarget: transactionTarget, pendingTransaction: pendingTransaction)
            .flatMap { [onChainEngine, orderUpdateRepository] pendingTransaction in
                onChainEngine
                    .execute(pendingTransaction: pendingTransaction)
                    .catch { [orderUpdateRepository] error -> Single<TransactionResult> in
                        orderUpdateRepository
                            .updateOrder(identifier: swapOrderIdentifier, success: false)
                            .asCompletable()
                            .catch { _ in .empty() }
                            .andThen(.error(error))
                    }
                    .flatMap { [orderUpdateRepository] result -> Single<TransactionResult> in
                        orderUpdateRepository
                            .updateOrder(identifier: swapOrderIdentifier, success: true)
                            .asCompletable()
                            .catch { _ in .empty() }
                            .andThen(.just(result))
                    }
            }
    }

    func doUpdateFeeLevel(
        pendingTransaction: PendingTransaction,
        level: FeeLevel,
        customFeeAmount: MoneyValue
    ) -> Single<PendingTransaction> {
        onChainEngine.doUpdateFeeLevel(
            pendingTransaction: pendingTransaction,
            level: level,
            customFeeAmount: customFeeAmount
        )
    }

    func update(amount: MoneyValue, pendingTransaction: PendingTransaction) -> Single<PendingTransaction> {
        validateUpdateAmount(amount)
            .flatMap { [onChainEngine] amount -> Single<PendingTransaction> in
                onChainEngine
                    .update(amount: amount, pendingTransaction: pendingTransaction)
                    .do(onSuccess: { [weak self] pendingTransaction in
                        guard let self else { throw ToolKitError.nullReference(Self.self) }
                        self.quotesEngine.update(amount: pendingTransaction.amount.minorAmount)
                    })
                    .map { [weak self] pendingTransaction -> PendingTransaction in
                        guard let self else { throw ToolKitError.nullReference(Self.self) }
                        return self.clearConfirmations(pendingTransaction: pendingTransaction)
                    }
            }
    }
}
