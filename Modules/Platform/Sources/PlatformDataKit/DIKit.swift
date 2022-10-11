// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit
import Foundation
import PlatformKit
import ToolKit

extension DependencyContainer {

    // MARK: - PlatformKit Module

    public static var platformDataKit = module {

        // MARK: - Interest

        factory { APIClient() as PlatformDataAPIClient }

        factory { () -> InterestAccountEligibilityClientAPI in
            let client: PlatformDataAPIClient = DIKit.resolve()
            return client as InterestAccountEligibilityClientAPI
        }

        factory { () -> InterestAccountReceiveAddressClientAPI in
            let client: PlatformDataAPIClient = DIKit.resolve()
            return client as InterestAccountReceiveAddressClientAPI
        }

        single { InterestAccountEligibilityRepository() as InterestAccountEligibilityRepositoryAPI }

        factory { InterestAccountReceiveAddressRepository() as InterestAccountReceiveAddressRepositoryAPI }

        // MARK: - Price

        factory { () -> PriceClientAPI in
            let client: PlatformDataAPIClient = DIKit.resolve()
            return client as PriceClientAPI
        }

        single {
            PriceRepository() as PriceRepositoryAPI
        }

        single(tag: DIKitPriceContext.volume) {
            PriceRepository(refreshControl: PerpetualCacheRefreshControl()) as PriceRepositoryAPI
        }
    }
}
