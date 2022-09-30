// Copyright © Blockchain Luxembourg S.A. All rights reserved.

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
        onComplete: @escaping () -> Void
    ) -> UIViewController

    func makeManagementView(
        onComplete: @escaping () -> Void
    ) -> AnyView
}

final class CardIssuingBuilder: CardIssuingBuilderAPI {

    private let accountModelProvider: AccountProviderAPI
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
        onComplete: @escaping () -> Void
    ) -> UIViewController {

        UIHostingController(
            rootView: makeManagementView(
                onComplete: onComplete
            )
        )
    }

    func makeManagementView(
        onComplete: @escaping () -> Void
    ) -> AnyView {

        let env = CardManagementEnvironment(
            accountModelProvider: accountModelProvider,
            cardService: cardService,
            mainQueue: .main,
            productsService: productService,
            transactionService: transactionService,
            supportRouter: supportRouter,
            userInfoProvider: userInfoProvider,
            topUpRouter: topUpRouter,
            addressSearchRouter: addressSearchRouter,
            notificationCenter: NotificationCenter.default,
            close: onComplete
        )

        let store = Store<CardManagementState, CardManagementAction>(
            initialState: .init(tokenisationCoordinator: PassTokenisationCoordinator(service: cardService)),
            reducer: cardManagementReducer,
            environment: env
        )

        return AnyView(CardManagementView(store: store))
    }
}
