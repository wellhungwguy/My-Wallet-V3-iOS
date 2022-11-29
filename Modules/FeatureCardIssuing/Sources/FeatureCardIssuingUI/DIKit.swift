// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit
import FeatureCardIssuingDomain

extension DependencyContainer {

    // MARK: - FeatureCardIssuingUI Module

    public static var featureCardIssuingUI = module {

        factory {
            CardIssuingBuilder(
                accountModelProvider: DIKit.resolve(),
                app: DIKit.resolve(),
                cardService: DIKit.resolve(),
                legalService: DIKit.resolve(),
                productService: DIKit.resolve(),
                residentialAddressService: DIKit.resolve(tag: CardIssuingTag.residentialAddress),
                shippingAddressService: DIKit.resolve(tag: CardIssuingTag.shippingAddress),
                transactionService: DIKit.resolve(),
                supportRouter: DIKit.resolve(),
                userInfoProvider: DIKit.resolve(),
                topUpRouter: DIKit.resolve(),
                addressSearchRouter: DIKit.resolve(tag: CardIssuingTag.residentialAddress),
                shippingAddressSearchRouter: DIKit.resolve(tag: CardIssuingTag.shippingAddress)
            ) as CardIssuingBuilderAPI
        }
    }
}
