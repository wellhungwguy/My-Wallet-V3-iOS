// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit

public enum CardIssuingTag: String {
    case residentialAddress
    case shippingAddress
}

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

        factory(tag: CardIssuingTag.residentialAddress) {
            AddressService(
                repository: DIKit.resolve(tag: CardIssuingTag.residentialAddress)
            ) as CardIssuingAddressServiceAPI
        }

        factory(tag: CardIssuingTag.shippingAddress) {
            AddressService(
                repository: DIKit.resolve(tag: CardIssuingTag.shippingAddress)
            ) as CardIssuingAddressServiceAPI
        }

        factory {
            TransactionService(
                repository: DIKit.resolve()
            ) as TransactionServiceAPI
        }

        factory {
            KYCService(
                repository: DIKit.resolve()
            ) as KYCServiceAPI
        }
    }
}
