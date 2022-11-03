// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit
import MoneyDomainKit
import ToolKit

extension DependencyContainer {

    // MARK: - MoneyKit Module

    public static var moneyDataKit = module {

        single { () -> EnabledCurrenciesServiceAPI in
            EnabledCurrenciesService(
                evmSupport: DIKit.resolve(),
                repository: DIKit.resolve()
            )
        }

        factory { () -> SupportedAssetsFilePathProviderAPI in
            SupportedAssetsFilePathProvider(
                fileManager: .default
            )
        }

        factory { () -> SupportedAssetsServiceAPI in
            SupportedAssetsService(
                errorLogger: DIKit.resolve(),
                filePathProvider: DIKit.resolve()
            )
        }

        factory { () -> SupportedAssetsRepositoryAPI in
            SupportedAssetsRepository(
                localService: DIKit.resolve(),
                evmSupport: DIKit.resolve()
            )
        }

        factory { () -> SupportedAssetsRemoteServiceAPI in
            SupportedAssetsRemoteService(
                client: DIKit.resolve(),
                filePathProvider: DIKit.resolve(),
                fileIO: DIKit.resolve(),
                jsonDecoder: .init()
            )
        }

        factory { () -> SupportedAssetsClientAPI in
            SupportedAssetsClient(
                requestBuilder: DIKit.resolve(),
                networkAdapter: DIKit.resolve()
            )
        }

        factory { () -> PriceClientAPI in
            PriceClient(
                networkAdapter: DIKit.resolve(),
                requestBuilder: DIKit.resolve()
            )
        }

        single { () -> PriceRepositoryAPI in
            PriceRepository(
                client: DIKit.resolve()
            )
        }

        single(tag: DIKitPriceContext.volume) { () -> PriceRepositoryAPI in
            PriceRepository(
                client: DIKit.resolve(),
                refreshControl: PerpetualCacheRefreshControl()
            )
        }

        factory { () -> EVMSupportAPI in
            EVMSupport(app: DIKit.resolve())
        }
    }
}
