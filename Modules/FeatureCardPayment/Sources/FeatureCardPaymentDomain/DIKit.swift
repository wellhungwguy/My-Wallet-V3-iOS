// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit

extension DependencyContainer {

    // MARK: - FeatureCardPaymentDomain Module

    public static var featureCardPaymentDomain = module {
        single { CardService() as CardServiceAPI }
        single { CardListService() as CardListServiceAPI }
        factory { CardUpdateService() as CardUpdateServiceAPI }
        factory { CardActivationService() as CardActivationServiceAPI }
        single {
            CardSuccessRateService(repository: DIKit.resolve()) as CardSuccessRateServiceAPI
        }
        single { ApplePayAuthorizationService() as ApplePayAuthorizationServiceAPI }
        single {
            ApplePayService(
                repository: DIKit.resolve(),
                authorizationService: DIKit.resolve()
            ) as ApplePayServiceAPI
        }
    }
}
