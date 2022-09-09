// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import DIKit
import MoneyKit
import PlatformKit
import RxSwift
import RxToolKit
import ToolKit

final class TradingToOnChainTransactionEngine: TransactionEngine {

    /// This might need to be `1:1` as there isn't a transaction pair.
    var transactionExchangeRatePair: Observable<MoneyValuePair> {
        .empty()
    }

    var fiatExchangeRatePairs: Observable<TransactionMoneyValuePairs> {
        sourceExchangeRatePair
            .map { pair -> TransactionMoneyValuePairs in
                TransactionMoneyValuePairs(
                    source: pair,
                    destination: pair
                )
            }
            .asObservable()
    }

    let walletCurrencyService: FiatCurrencyServiceAPI
    let currencyConversionService: CurrencyConversionServiceAPI
    let isNoteSupported: Bool
    var askForRefreshConfirmation: AskForRefreshConfirmation!
    var sourceAccount: BlockchainAccount!
    var transactionTarget: TransactionTarget!

    var sourceTradingAccount: CryptoTradingAccount! {
        sourceAccount as? CryptoTradingAccount
    }

    var target: CryptoReceiveAddress {
        transactionTarget as! CryptoReceiveAddress
    }

    var targetAsset: CryptoCurrency { target.asset }

    // MARK: - Private Properties

    private let feeCache: CachedValue<CustodialTransferFee>
    private let transferRepository: CustodialTransferRepositoryAPI
    private let transactionLimitsService: TransactionLimitsServiceAPI

    // MARK: - Init

    init(
        isNoteSupported: Bool = false,
        walletCurrencyService: FiatCurrencyServiceAPI = resolve(),
        currencyConversionService: CurrencyConversionServiceAPI = resolve(),
        transferRepository: CustodialTransferRepositoryAPI = resolve(),
        transactionLimitsService: TransactionLimitsServiceAPI = resolve()
    ) {
        self.walletCurrencyService = walletCurrencyService
        self.currencyConversionService = currencyConversionService
        self.isNoteSupported = isNoteSupported
        self.transferRepository = transferRepository
        self.transactionLimitsService = transactionLimitsService
        feeCache = CachedValue(
            configuration: .periodic(
                seconds: 20,
                schedulerIdentifier: "TradingToOnChainTransactionEngine"
            )
        )
        feeCache.setFetch(weak: self) { (self) -> Single<CustodialTransferFee> in
            self.transferRepository.fees()
                .asSingle()
        }
    }

    func assertInputsValid() {
        precondition(transactionTarget is CryptoReceiveAddress)
        precondition(sourceAsset == targetAsset)
    }

    func restart(
        transactionTarget: TransactionTarget,
        pendingTransaction: PendingTransaction
    ) -> Single<PendingTransaction> {
        let memoModel = TransactionConfirmations.Memo(
            textMemo: target.memo,
            required: false
        )
        return defaultRestart(
            transactionTarget: transactionTarget,
            pendingTransaction: pendingTransaction
        )
        .map { [sourceTradingAccount] pendingTransaction -> PendingTransaction in
            guard sourceTradingAccount!.isMemoSupported else {
                return pendingTransaction
            }
            var pendingTransaction = pendingTransaction
            pendingTransaction.setMemo(memo: memoModel)
            return pendingTransaction
        }
    }

    func initializeTransaction() -> Single<PendingTransaction> {
        let memoModel = TransactionConfirmations.Memo(
            textMemo: target.memo,
            required: false
        )
        let transactionLimits = transactionLimitsService
            .fetchLimits(
                source: LimitsAccount(
                    currency: sourceAccount.currencyType,
                    accountType: .custodial
                ),
                destination: LimitsAccount(
                    currency: targetAsset.currencyType,
                    accountType: .nonCustodial // even exchange accounts are considered non-custodial atm.
                )
            )

        return transactionLimits.eraseError()
            .zip(walletCurrencyService.displayCurrencyPublisher.eraseError())
            .map { [sourceTradingAccount, sourceAsset, predefinedAmount] transactionLimits, walletCurrency
                -> PendingTransaction in
                let amount: MoneyValue
                if let predefinedAmount = predefinedAmount,
                   predefinedAmount.currencyType == sourceAsset
                {
                    amount = predefinedAmount
                } else {
                    amount = .zero(currency: sourceAsset)
                }
                var pendingTransaction = PendingTransaction(
                    amount: amount,
                    available: .zero(currency: sourceAsset),
                    feeAmount: .zero(currency: sourceAsset),
                    feeForFullAvailable: .zero(currency: sourceAsset),
                    feeSelection: .empty(asset: sourceAsset),
                    selectedFiatCurrency: walletCurrency,
                    limits: transactionLimits
                )
                if sourceTradingAccount!.isMemoSupported {
                    pendingTransaction.setMemo(memo: memoModel)
                }
                return pendingTransaction
            }
            .asSingle()
    }

    func update(amount: MoneyValue, pendingTransaction: PendingTransaction) -> Single<PendingTransaction> {
        guard sourceTradingAccount != nil else {
            return .just(pendingTransaction)
        }
        return
            Single
                .zip(
                    feeCache.valueSingle,
                    sourceTradingAccount.withdrawableBalance.asSingle()
                )
                .map { fees, withdrawableBalance -> PendingTransaction in
                    let fee = fees[fee: amount.currency]
                    let available = try withdrawableBalance - fee
                    var pendingTransaction = pendingTransaction.update(
                        amount: amount,
                        available: available.isNegative ? .zero(currency: available.currency) : available,
                        fee: fee,
                        feeForFullAvailable: fee
                    )
                    let transactionLimits = pendingTransaction.limits ?? .noLimits(for: amount.currency)
                    pendingTransaction.limits = TransactionLimits(
                        currencyType: transactionLimits.currencyType,
                        minimum: fees[minimumAmount: amount.currency],
                        maximum: transactionLimits.maximum,
                        maximumDaily: transactionLimits.maximumDaily,
                        maximumAnnual: transactionLimits.maximumAnnual,
                        effectiveLimit: transactionLimits.effectiveLimit,
                        suggestedUpgrade: transactionLimits.suggestedUpgrade
                    )
                    return pendingTransaction
                }
    }

    func doBuildConfirmations(pendingTransaction: PendingTransaction) -> Single<PendingTransaction> {
        fiatAmountAndFees(from: pendingTransaction)
            .map { [sourceTradingAccount, target, isNoteSupported] fiatAmountAndFees -> [TransactionConfirmation] in
                var confirmations: [TransactionConfirmation] = [
                    TransactionConfirmations.Source(value: sourceTradingAccount!.label),
                    TransactionConfirmations.Destination(value: target.label),
                    TransactionConfirmations.NetworkFee(
                        primaryCurrencyFee: fiatAmountAndFees.fees.moneyValue,
                        feeType: .withdrawalFee
                    ),
                    TransactionConfirmations.Total(total: fiatAmountAndFees.amount.moneyValue)
                ]
                if isNoteSupported {
                    confirmations.append(TransactionConfirmations.Destination(value: ""))
                }
                if sourceTradingAccount!.isMemoSupported {
                    confirmations.append(
                        TransactionConfirmations.Memo(textMemo: target.memo, required: false)
                    )
                }
                return confirmations
            }
            .map { confirmations -> PendingTransaction in
                pendingTransaction.update(confirmations: confirmations)
            }
    }

    func doOptionUpdateRequest(
        pendingTransaction: PendingTransaction,
        newConfirmation: TransactionConfirmation
    ) -> Single<PendingTransaction> {
        defaultDoOptionUpdateRequest(pendingTransaction: pendingTransaction, newConfirmation: newConfirmation)
            .map { pendingTransaction -> PendingTransaction in
                var pendingTransaction = pendingTransaction
                if let memo = newConfirmation as? TransactionConfirmations.Memo {
                    pendingTransaction.setMemo(memo: memo)
                }
                return pendingTransaction
            }
    }

    func doValidateAll(pendingTransaction: PendingTransaction) -> Single<PendingTransaction> {
        validateAmount(pendingTransaction: pendingTransaction)
    }

    func execute(pendingTransaction: PendingTransaction) -> Single<TransactionResult> {
        transferRepository
            .transfer(
                moneyValue: pendingTransaction.amount,
                destination: target.address,
                memo: pendingTransaction.memo?.value?.string
            )
            .map { identifier -> TransactionResult in
                .hashed(txHash: identifier, amount: pendingTransaction.amount)
            }
            .asSingle()
    }

    func doUpdateFeeLevel(
        pendingTransaction: PendingTransaction,
        level: FeeLevel,
        customFeeAmount: MoneyValue
    ) -> Single<PendingTransaction> {
        .just(pendingTransaction)
    }

    // MARK: - Private Functions

    private func fiatAmountAndFees(
        from pendingTransaction: PendingTransaction
    ) -> Single<(amount: FiatValue, fees: FiatValue)> {
        Single.zip(
            sourceExchangeRatePair,
            .just(pendingTransaction.amount.cryptoValue ?? .zero(currency: sourceCryptoCurrency)),
            .just(pendingTransaction.feeAmount.cryptoValue ?? .zero(currency: sourceCryptoCurrency))
        )
        .map { (quote: $0.0.quote.fiatValue ?? .zero(currency: .USD), amount: $0.1, fees: $0.2) }
        .map { (quote: FiatValue, amount: CryptoValue, fees: CryptoValue) -> (FiatValue, FiatValue) in
            let fiatAmount = amount.convert(using: quote)
            let fiatFees = fees.convert(using: quote)
            return (fiatAmount, fiatFees)
        }
        .map { (amount: $0.0, fees: $0.1) }
    }

    private var sourceExchangeRatePair: Single<MoneyValuePair> {
        walletCurrencyService
            .displayCurrency
            .flatMap { [currencyConversionService, sourceAsset] fiatCurrency in
                currencyConversionService
                    .conversionRate(from: sourceAsset, to: fiatCurrency.currencyType)
                    .map { MoneyValuePair(base: .one(currency: sourceAsset), quote: $0) }
            }
            .asSingle()
    }
}

extension CryptoTradingAccount {
    fileprivate var isMemoSupported: Bool {
        switch asset {
        case .stellar:
            return true
        default:
            return false
        }
    }
}

extension PendingTransaction {

    fileprivate var memo: TransactionConfirmations.Memo? {
        engineState.value[.xlmMemo] as? TransactionConfirmations.Memo
    }

    fileprivate mutating func setMemo(memo: TransactionConfirmations.Memo) {
        engineState.mutate { $0[.xlmMemo] = memo }
    }
}
