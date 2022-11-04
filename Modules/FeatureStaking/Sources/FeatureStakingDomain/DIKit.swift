// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit
import PlatformKit

extension DependencyContainer {

    // MARK: - FeatureInterestData Module

    public static var featureStakingDomainKit = module {

        single { () -> StakingAccountServiceAPI in
            StakingAccountService(
                balanceRepository: DIKit.resolve(),
                fiatCurrencyService: DIKit.resolve(),
                kycTiersService: DIKit.resolve(),
                priceService: DIKit.resolve()
            )
        }

        factory { () -> StakingAccountOverviewAPI in
            let service: StakingAccountServiceAPI = DIKit.resolve()
            return service as StakingAccountOverviewAPI
        }
    }
}
