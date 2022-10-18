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
        if let newCheckout { return newCheckout }
        let detailsPresenter = ConfirmationPageDetailsPresenter()
        let viewController = DetailsScreenViewController(presenter: detailsPresenter)
        let interactor = ConfirmationPageInteractor(presenter: detailsPresenter, transactionModel: transactionModel)
        interactor.listener = listener
        return ConfirmationPageRouter(interactor: interactor, viewController: viewController)
    }

    var newCheckout: ViewableRouter<Interactable, ViewControllable>? {

        guard app.remoteConfiguration.yes(
            if: blockchain.ux.transaction.checkout.is.enabled
        ) else { return nil }

        let viewController: UIViewController
        switch action {
        case .swap:
            viewController = buildSwapCheckout(for: transactionModel)
        case .buy:
            viewController = buildBuyCheckout(for: transactionModel)
        default:
            return nil
        }

        return ViewableRouter(
            interactor: Interactor(),
            viewController: viewController
        )
    }
}

// MARK: - Swap

extension ConfirmationPageBuilder {

    func pendingTransactions(for transactionModel: TransactionModel) -> AnyPublisher<TransactionState, Never> {
        transactionModel.state.publisher
            .ignoreFailure(setFailureType: Never.self)
            .removeDuplicates(by: { old, new in old.pendingTransaction == new.pendingTransaction })
            .eraseToAnyPublisher()
    }

    private func buildBuyCheckout(for transactionModel: TransactionModel) -> UIViewController {

        let publisher = pendingTransactions(for: transactionModel).compactMap(\.buyCheckout)

        let viewController = UIHostingController(
            rootView: BuyCheckoutView(publisher: publisher)
                .onAppear { transactionModel.process(action: .validateTransaction) }
                .navigationTitle(LocalizationConstants.Checkout.buyTitle)
                .navigationBarBackButtonHidden(true)
                .navigationBarTitleDisplayMode(.inline)
                .whiteNavigationBarStyle()
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

    private func buildSwapCheckout(for transactionModel: TransactionModel) -> UIViewController {

        let publisher = pendingTransactions(for: transactionModel)
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
                .whiteNavigationBarStyle()
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

    var buyCheckout: BuyCheckout? {
        guard let pendingTransaction, let source else { return nil }
        do {
            let value = try pendingTransaction.confirmations.lazy
                .filter(TransactionConfirmations.BuyCryptoValue.self).first.or(throw: "No value confirmation")
            let purchase = try (pendingTransaction.confirmations.lazy
                .filter(TransactionConfirmations.Purchase.self).first?.purchase).or(throw: "No purchase confirmation")
            let exchangeRate = try pendingTransaction.confirmations.lazy
                .filter(TransactionConfirmations.BuyExchangeRateValue.self).first.or(throw: "No exchangeRate")
            let paymentMethod = try pendingTransaction.confirmations.lazy
                .filter(TransactionConfirmations.BuyPaymentMethodValue.self).first.or(throw: "No paymentMethod")
            let total = try (pendingTransaction.confirmations.lazy
                .filter(TransactionConfirmations.Total.self).first?.total).or(throw: "No total confirmation")
            let fee = try pendingTransaction.confirmations.lazy
                .filter(TransactionConfirmations.FiatTransactionFee.self).first.or(throw: "No fee")

            let paymentMethodAccount = source as? PaymentMethodAccount
            let name: String
            let detail: String?

            switch paymentMethodAccount?.paymentMethodType {
            case .card(let card):
                name = card.type.name
                detail = card.displaySuffix
            case .applePay(let apple):
                name = "Apple Pay"
                detail = apple.displaySuffix
            case .account:
                name = "Funds"
                detail = nil
            case .linkedBank(let bank):
                name = bank.account?.bankName ?? "Bank"
                detail = bank.account?.number
            case _:
                name = paymentMethod.name
                detail = nil
            }

            return try BuyCheckout(
                input: value.baseValue,
                purchase: MoneyValuePair(
                    fiatValue: purchase.fiatValue.or(throw: "Amount is not fiat"),
                    exchangeRate: exchangeRate.baseValue.fiatValue.or(throw: "No exchange rate"),
                    cryptoCurrency: CryptoCurrency(code: value.baseValue.code).or(throw: "Input is not a crypto value"),
                    usesFiatAsBase: false
                ),
                fee: .init(
                    value: fee.fee.fiatValue.or(throw: "Fee is not in fiat"),
                    promotion: nil
                ),
                total: total.fiatValue.or(throw: "No total value"),
                paymentMethod: .init(
                    name: name,
                    detail: detail,
                    isApplePay: paymentMethodAccount?.paymentMethod.type.isApplePay == true
                ),
                quoteExpiration: pendingTransaction.confirmations.lazy
                    .filter(TransactionConfirmations.QuoteExpirationTimer.self).first?.expirationDate
            )
        } catch {
            return nil
        }
    }

    var swapCheckout: SwapCheckout? {
        guard let pendingTransaction else { return nil }
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
