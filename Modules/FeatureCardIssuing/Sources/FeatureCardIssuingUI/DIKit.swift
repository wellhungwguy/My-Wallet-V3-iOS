// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit
import FeatureCardIssuingDomain

extension DependencyContainer {

    // MARK: - FeatureCardIssuingUI Module

    public static var featureCardIssuingUI = module {

        factory {
            CardIssuingBuilder(
                accountModelProvider: DIKit.resolve(),
                cardService: DIKit.resolve(),
                legalService: DIKit.resolve(),
                productService: DIKit.resolve(),
                addressService: DIKit.resolve(),
                transactionService: DIKit.resolve(),
                supportRouter: DIKit.resolve(),
                topUpRouter: DIKit.resolve(),
                addressSearchRouter: DIKit.resolve()
            ) as CardIssuingBuilderAPI
        }
    }
}
