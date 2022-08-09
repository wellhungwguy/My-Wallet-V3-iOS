// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import DIKit
import FeatureCardPaymentDomain

extension DependencyContainer {

    // MARK: - FeatureCardPaymentData Module

    public static var featureCardPaymentData = module {
        // MARK: - Clients - Cards

        factory { CardClient() as CardClientAPI }

        factory { EveryPayClient() as EveryPayClientAPI }

        factory { () -> CardListClientAPI in
            let client: CardClientAPI = DIKit.resolve()
            return client as CardListClientAPI
        }

        factory { () -> CardDeletionClientAPI in
            let client: CardClientAPI = DIKit.resolve()
            return client as CardDeletionClientAPI
        }

        factory { () -> CardDetailClientAPI in
            let client: CardClientAPI = DIKit.resolve()
            return client as CardDetailClientAPI
        }

        factory { () -> CardSuccessRateClientAPI in
            let client: CardClientAPI = DIKit.resolve()
            return client as CardSuccessRateClientAPI
        }

        // MARK: - Repositories - Cards

        single { CardListRepository() as CardListRepositoryAPI }

        single { CardSuccessRateRepository() as CardSuccessRateRepositoryAPI }

        factory {
            ApplePayRepository(
                client: DIKit.resolve(),
                eligibleService: DIKit.resolve()
            ) as ApplePayRepositoryAPI
        }

        factory { CardAcquirersRepository() as CardAcquirersRepositoryAPI }
    }
}
