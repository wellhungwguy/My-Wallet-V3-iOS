// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit

extension DependencyContainer {

    // MARK: - MoneyKit Module

    public static var moneyKit = module {

        single { () -> EnabledCurrenciesServiceAPI in
            EnabledCurrenciesService(
                evmSupport: DIKit.resolve(),
                repository: DIKit.resolve()
            )
        }

        factory { SupportedAssetsFilePathProvider() as SupportedAssetsFilePathProviderAPI }

        factory { SupportedAssetsService() as SupportedAssetsServiceAPI }

        factory { () -> SupportedAssetsRepositoryAPI in
            SupportedAssetsRepository(
                localService: DIKit.resolve(),
                evmSupport: DIKit.resolve()
            )
        }

        factory { SupportedAssetsRemoteService() as SupportedAssetsRemoteServiceAPI }

        factory { SupportedAssetsClient() as SupportedAssetsClientAPI }
    }
}
