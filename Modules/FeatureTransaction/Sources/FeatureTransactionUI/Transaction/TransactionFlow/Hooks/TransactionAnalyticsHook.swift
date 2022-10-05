// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import AnalyticsKit
import BlockchainNamespace
import Combine
import DIKit
import FeatureTransactionDomain
import MoneyKit
import PlatformKit
import ToolKit

final class TransactionAnalyticsHook {

    typealias LegacySwapAnalyticsEvent = AnalyticsEvents.Swap
    typealias SwapAnalyticsEvent = AnalyticsEvents.New.Swap
    typealias SendAnalyticsEvent = AnalyticsEvents.New.Send

    private let app: AppProtocol
    private let analyticsRecorder: AnalyticsEventRecorderAPI
    private let pricesService: PriceServiceAPI
    private var cancellables = Set<AnyCancellable>()

    init(
        app: AppProtocol = resolve(),
        analyticsRecorder: AnalyticsEventRecorderAPI = resolve(),
        pricesService: PriceServiceAPI = resolve()
    ) {
        self.app = app
        self.analyticsRecorder = analyticsRecorder
        self.pricesService = pricesService
    }

    func onFeeSelected(state: TransactionState) {
        switch state.action {
        case .send:
            guard let target = state.destination as? CryptoAccount,
                  let source = state.source as? CryptoAccount,
                  let feeSelectionAsset = state.feeSelection.asset
            else {
                return
            }
            analyticsRecorder.record(event:
                SendAnalyticsEvent.sendFeeRateSelected(
                    currency: feeSelectionAsset.code,
                    feeRate: .init(state.feeSelection.selectedLevel),
                    fromAccountType: .init(source),
                    toAccountType: .init(target)
                )
            )
        default:
            break
        }
    }

    func onMinSelected(state: TransactionState) {
        app.post(event: blockchain.ux.transaction.enter.amount.button.min.tap)
    }

    func onMaxSelected(state: TransactionState) {
        app.post(event: blockchain.ux.transaction.enter.amount.button.max.tap)
    }

    func onTransactionSubmitted(with state: TransactionState) {
        switch state.action {
        case .swap:
            guard let target = state.destination as? CryptoAccount,
                  let source = state.source as? CryptoAccount,
                  let exchangeRate = state.exchangeRates?.sourceToDestinationTradingCurrencyRate
            else {
                return
            }
            let confirmations = state.pendingTransaction?
                .confirmations
                .compactMap { confirmation -> TransactionConfirmations.NetworkFee? in
                    guard let networkFee = confirmation as? TransactionConfirmations.NetworkFee else {
                        return nil
                    }
                    return networkFee
                }
            let networkFeeInputAmount = confirmations?.first(where: {
                $0.feeType == .withdrawalFee
            })?.primaryCurrencyFee.displayMajorValue.doubleValue ?? 0
            let networkFeeOutputAmount = confirmations?.first(where: {
                $0.feeType == .depositFee
            })?.primaryCurrencyFee.displayMajorValue.doubleValue ?? 0
            analyticsRecorder.record(events: [
                LegacySwapAnalyticsEvent.transactionSuccess(
                    asset: state.asset,
                    source: state.asset.name,
                    target: target.label
                ),
                SwapAnalyticsEvent.swapRequested(
                    exchangeRate: exchangeRate.displayMajorValue.doubleValue,
                    inputAmount: state.amount.displayMajorValue.doubleValue,
                    inputCurrency: source.currencyType.code,
                    inputType: .init(source),
                    networkFeeInputAmount: networkFeeInputAmount,
                    networkFeeInputCurrency: source.currencyType.code,
                    networkFeeOutputAmount: networkFeeOutputAmount,
                    networkFeeOutputCurrency: target.currencyType.code,
                    outputAmount: state.amount.convert(using: exchangeRate).displayMajorValue.doubleValue,
                    outputCurrency: target.currencyType.code,
                    outputType: .init(target)
                )
            ])
        case .send:
            analyticsRecorder.record(event:
                SendAnalyticsEvent.sendSubmitted(
                    currency: state.destination?.currencyType.code ?? "",
                    feeRate: .init(state.feeSelection.selectedLevel),
                    fromAccountType: .init(state.source),
                    toAccountType: .init(state.destination)
                )
            )
        case .interestTransfer:
            guard let currency = state.source?.currencyType.cryptoCurrency else {
                return
            }
            pricesService.price(of: currency, in: FiatCurrency.USD)
                .sink { [analyticsRecorder] price in
                    let exchangeRate = MoneyValuePair(
                        base: .one(currency: state.amount.currency),
                        quote: price.moneyValue
                    )
                    let amountUsd = try? state.amount.convert(using: exchangeRate)
                    analyticsRecorder.record(
                        event: .walletRewardsDepositTransferClicked(
                            amount: state.amount.displayMajorValue.doubleValue,
                            amountUsd: amountUsd?.displayMajorValue.doubleValue ?? 0,
                            currency: state.source?.currencyType.code ?? "",
                            type: .init(state.source)
                        )
                    )
                }
                .store(in: &cancellables)

        case .interestWithdraw:
            guard let currency = state.source?.currencyType.cryptoCurrency else {
                return
            }
            pricesService.price(of: currency, in: FiatCurrency.USD)
                .sink { [analyticsRecorder] price in
                    let exchangeRate = MoneyValuePair(
                        base: .one(currency: state.amount.currency),
                        quote: price.moneyValue
                    )
                    let amountUsd = try? state.amount.convert(using: exchangeRate)
                    analyticsRecorder.record(
                        event: .walletRewardsWithdrawTransferClicked(
                            amount: state.amount.displayMajorValue.doubleValue,
                            amountUsd: amountUsd?.displayMajorValue.doubleValue ?? 0,
                            currency: state.source?.currencyType.code ?? "",
                            type: .init(state.source)
                        )
                    )
                }
                .store(in: &cancellables)
        default:
            break
        }
    }

    func onTransactionFailure(with state: TransactionState) {

        let tx = state

        app.state.transaction { state in
            state.set(blockchain.ux.error.context.action, to: tx.action)
            state.set(blockchain.ux.error.context.type, to: tx.errorState.label)
        }
    }
}
