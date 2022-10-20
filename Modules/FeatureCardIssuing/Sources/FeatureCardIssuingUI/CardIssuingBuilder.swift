// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainNamespace
import Combine
import ComposableArchitecture
import FeatureCardIssuingDomain
import SwiftUI
import UIKit

public protocol CardIssuingBuilderAPI: AnyObject {

    func makeIntroViewController(
        address: AnyPublisher<Card.Address, CardOrderingError>,
        onComplete: @escaping (CardOrderingResult) -> Void
    ) -> UIViewController

    func makeIntroView(
        address: AnyPublisher<Card.Address, CardOrderingError>,
        onComplete: @escaping (CardOrderingResult) -> Void
    ) -> AnyView

    func makeManagementViewController(
        openAddCardFlow: @escaping () -> Void,
        onComplete: @escaping () -> Void
    ) -> UIViewController

    func makeManagementView(
        openAddCardFlow: @escaping () -> Void,
        onComplete: @escaping () -> Void
    ) -> AnyView
}

final class CardIssuingBuilder: CardIssuingBuilderAPI {

    private let accountModelProvider: AccountProviderAPI
    private let app: AppProtocol
    private let cardService: CardServiceAPI
    private let legalService: LegalServiceAPI
    private let productService: ProductsServiceAPI
    private let addressService: ResidentialAddressServiceAPI
    private let transactionService: TransactionServiceAPI
    private let supportRouter: SupportRouterAPI
    private let userInfoProvider: UserInfoProviderAPI
    private let topUpRouter: TopUpRouterAPI
    private let addressSearchRouter: AddressSearchRouterAPI

    init(
        accountModelProvider: AccountProviderAPI,
        app: AppProtocol,
        cardService: CardServiceAPI,
        legalService: LegalServiceAPI,
        productService: ProductsServiceAPI,
        addressService: ResidentialAddressServiceAPI,
        transactionService: TransactionServiceAPI,
        supportRouter: SupportRouterAPI,
        userInfoProvider: UserInfoProviderAPI,
        topUpRouter: TopUpRouterAPI,
        addressSearchRouter: AddressSearchRouterAPI
    ) {
        self.accountModelProvider = accountModelProvider
        self.app = app
        self.cardService = cardService
        self.legalService = legalService
        self.productService = productService
        self.addressService = addressService
        self.transactionService = transactionService
        self.supportRouter = supportRouter
        self.userInfoProvider = userInfoProvider
        self.topUpRouter = topUpRouter
        self.addressSearchRouter = addressSearchRouter
    }

    func makeIntroViewController(
        address: AnyPublisher<Card.Address, CardOrderingError>,
        onComplete: @escaping (CardOrderingResult) -> Void
    ) -> UIViewController {

        UIHostingController(
            rootView: makeIntroView(
                address: address,
                onComplete: onComplete
            )
        )
    }

    func makeIntroView(
        address: AnyPublisher<Card.Address, CardOrderingError>,
        onComplete: @escaping (CardOrderingResult) -> Void
    ) -> AnyView {

        let env = CardOrderingEnvironment(
            mainQueue: .main,
            cardService: cardService,
            legalService: legalService,
            productsService: productService,
            addressService: addressService,
            addressSearchRouter: addressSearchRouter,
            onComplete: onComplete
        )

        let store = Store<CardOrderingState, CardOrderingAction>(
            initialState: .init(),
            reducer: cardOrderingReducer,
            environment: env
        )

        return AnyView(CardIssuingIntroView(store: store))
    }

    func makeManagementViewController(
        openAddCardFlow: @escaping () -> Void,
        onComplete: @escaping () -> Void
    ) -> UIViewController {

        UIHostingController(
            rootView: makeManagementView(
                openAddCardFlow: openAddCardFlow,
                onComplete: onComplete
            )
        )
    }

    func makeManagementView(
        openAddCardFlow: @escaping () -> Void,
        onComplete: @escaping () -> Void
    ) -> AnyView {

        let env = CardManagementEnvironment(
            accountModelProvider: accountModelProvider,
            cardIssuingBuilder: self,
            cardService: cardService,
            mainQueue: .main,
            productsService: productService,
            transactionService: transactionService,
            supportRouter: supportRouter,
            userInfoProvider: userInfoProvider,
            topUpRouter: topUpRouter,
            addressSearchRouter: addressSearchRouter,
            notificationCenter: NotificationCenter.default,
            openAddCardFlow: openAddCardFlow,
            close: onComplete
        )

        let store = Store<CardManagementState, CardManagementAction>(
            initialState: .init(
                isTokenisationEnabled: isEnabled(blockchain.app.configuration.card.issuing.tokenise.is.enabled),
                tokenisationCoordinator: PassTokenisationCoordinator(service: cardService)
            ),
            reducer: cardManagementReducer,
            environment: env
        )

        return AnyView(CardManagementView(store: store))
    }

    private func isEnabled(_ tag: Tag.Event) -> Bool {
        guard let value = try? app.remoteConfiguration.get(tag) else {
            return false
        }
        guard let isEnabled = value as? Bool else {
            return false
        }
        return isEnabled
    }
}
