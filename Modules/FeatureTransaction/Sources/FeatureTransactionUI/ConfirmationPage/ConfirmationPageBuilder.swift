// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainComponentLibrary
import BlockchainNamespace
import Combine
import ComposableArchitecture
import DIKit
import Extensions
import FeatureCheckoutUI
import FeatureTransactionDomain
import Localization
import MoneyKit
import PlatformKit
import PlatformUIKit
import RIBs
import SwiftUI
import UIKit

protocol ConfirmationPageListener: AnyObject {
    func closeFlow()
    func checkoutDidTapBack()
}

protocol ConfirmationPageBuildable {
    func build(listener: ConfirmationPageListener) -> ViewableRouter<Interactable, ViewControllable>
}

final class ConfirmationPageBuilder: ConfirmationPageBuildable {
    private let transactionModel: TransactionModel
    private let action: AssetAction
    private let app: AppProtocol
    private let priceService: PriceServiceAPI
    private let fiatCurrencyService: FiatCurrencyServiceAPI

    init(
        transactionModel: TransactionModel,
        action: AssetAction,
        priceService: PriceServiceAPI = resolve(),
        fiatCurrencyService: FiatCurrencyServiceAPI = resolve(),
        app: AppProtocol = DIKit.resolve()
    ) {
        self.transactionModel = transactionModel
        self.action = action
        self.priceService = priceService
        self.fiatCurrencyService = fiatCurrencyService
        self.app = app
    }

    func build(listener: ConfirmationPageListener) -> ViewableRouter<Interactable, ViewControllable> {
        switch action {
        case .swap where app.remoteConfiguration.yes(if: blockchain.ux.transaction.checkout.is.enabled):
            return ViewableRouter(
                interactor: Interactor(),
                viewController: buildSwapCheckout(for: transactionModel)
            )
        default:
            let detailsPresenter = ConfirmationPageDetailsPresenter()
            let viewController = DetailsScreenViewController(presenter: detailsPresenter)
            let interactor = ConfirmationPageInteractor(presenter: detailsPresenter, transactionModel: transactionModel)
            interactor.listener = listener
            return ConfirmationPageRouter(interactor: interactor, viewController: viewController)
        }
    }
}

// MARK: - Swap

extension ConfirmationPageBuilder {

    private func buildSwapCheckout(for transactionModel: TransactionModel) -> UIViewController {

        let publisher = transactionModel.state.publisher
            .removeDuplicates(by: { old, new in old.pendingTransaction == new.pendingTransaction })
            .ignoreFailure()
            .task { [app, priceService] state -> SwapCheckout? in
                guard var checkout = state.swapCheckout else { return nil }
                do {
                    let currency: FiatCurrency = try await app.get(blockchain.user.currency.preferred.fiat.display.currency)

                    let sourceExchangeRate = try await priceService.price(of: checkout.from.cryptoValue.currency, in: currency)
                        .exchangeRatePair(checkout.from.cryptoValue.currency)
                        .await()

                    let sourceFeeExchangeRate = try await priceService.price(of: checkout.from.fee.currency, in: currency)
                        .exchangeRatePair(checkout.from.fee.currency)
                        .await()

                    let destinationExchangeRate = try await priceService.price(of: checkout.to.cryptoValue.currency, in: currency)
                        .exchangeRatePair(checkout.to.cryptoValue.currency)
                        .await()

                    checkout.from.exchangeRateToFiat = sourceExchangeRate
                    checkout.from.feeExchangeRateToFiat = sourceFeeExchangeRate

                    checkout.to.exchangeRateToFiat = destinationExchangeRate
                    checkout.to.feeExchangeRateToFiat = destinationExchangeRate

                    return checkout
                } catch {
                    return checkout
                }
            }
            .compactMap { $0 }

        let viewController = UIHostingController(
            rootView: SwapCheckoutView()
                .onAppear { transactionModel.process(action: .validateTransaction) }
                .environmentObject(SwapCheckoutView.Object(publisher: publisher.receive(on: DispatchQueue.main)))
                .navigationTitle(LocalizationConstants.Checkout.swapTitle)
                .navigationBarBackButtonHidden(true)
                .navigationBarItems(
                    leading: IconButton(
                        icon: .chevronLeft,
                        action: { [app] in
                            transactionModel.process(action: .returnToPreviousStep)
                            app.post(event: blockchain.ux.transaction.checkout.article.plain.navigation.bar.button.back)
                        }
                    )
                )
                .app(app)
        )
        viewController.isModalInPresentation = true

        app.on(blockchain.ux.transaction.checkout.confirmed) { _ in
            transactionModel.process(action: .executeTransaction)
        }
        .subscribe()
        .store(withLifetimeOf: viewController)

        return viewController
    }
}

extension Publisher where Output == PriceQuoteAtTime {

    func exchangeRatePair(_ currency: CryptoCurrency) -> AnyPublisher<MoneyValuePair, Failure> {
        map { MoneyValuePair(base: .one(currency: currency), exchangeRate: $0.moneyValue) }
            .eraseToAnyPublisher()
    }
}

extension TransactionState {

    var swapCheckout: SwapCheckout? {
        guard let pendingTransaction = pendingTransaction else { return nil }
        guard
            let sourceValue = pendingTransaction.confirmations.lazy
                .filter(TransactionConfirmations.SwapSourceValue.self).first?.cryptoValue,
            let destinationValue = pendingTransaction.confirmations.lazy
                .filter(TransactionConfirmations.SwapDestinationValue.self).first?.cryptoValue,
            let source = pendingTransaction.confirmations.lazy
                .filter(TransactionConfirmations.Source.self).first?.value,
            let destination = pendingTransaction.confirmations.lazy
                .filter(TransactionConfirmations.Destination.self).first?.value
        else { return nil }
        let sourceFee = pendingTransaction.confirmations.lazy
            .filter(TransactionConfirmations.NetworkFee.self)
            .first(where: \.feeType == .depositFee)?.primaryCurrencyFee.cryptoValue
        let destinationFee = pendingTransaction.confirmations.lazy
            .filter(TransactionConfirmations.NetworkFee.self)
            .first(where: \.feeType == .withdrawalFee)?.primaryCurrencyFee.cryptoValue
        let quoteExpiration = pendingTransaction.confirmations.lazy
            .filter(TransactionConfirmations.QuoteExpirationTimer.self).first?.expirationDate

        return SwapCheckout(
            from: SwapCheckout.Target(
                name: source,
                isPrivateKey: self.source?.accountType == .nonCustodial,
                cryptoValue: sourceValue,
                fee: sourceFee ?? .zero(currency: sourceValue.currency),
                exchangeRateToFiat: nil,
                feeExchangeRateToFiat: nil
            ),
            to: SwapCheckout.Target(
                name: destination,
                isPrivateKey: self.destination?.accountType == .nonCustodial,
                cryptoValue: destinationValue,
                fee: destinationFee ?? .zero(currency: destinationValue.currency),
                exchangeRateToFiat: nil,
                feeExchangeRateToFiat: nil
            ),
            quoteExpiration: quoteExpiration
        )
    }
}
