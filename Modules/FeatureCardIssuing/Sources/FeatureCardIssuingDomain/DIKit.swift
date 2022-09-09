// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit

extension DependencyContainer {

    // MARK: - FeatureCardIssuingDomain Module

    public static var featureCardIssuingDomain = module {

        factory {
            CardService(
                repository: DIKit.resolve()
            ) as CardServiceAPI
        }

        factory {
            LegalService(
                repository: DIKit.resolve()
            ) as LegalServiceAPI
        }

        factory {
            ProductsService(
                repository: DIKit.resolve()
            ) as ProductsServiceAPI
        }

        factory {
            RewardsService(
                repository: DIKit.resolve()
            ) as RewardsServiceAPI
        }

        factory {
            ResidentialAddressService(
                repository: DIKit.resolve()
            ) as ResidentialAddressServiceAPI
        }

        factory {
            TransactionService(
                repository: DIKit.resolve()
            ) as TransactionServiceAPI
        }
    }
}
