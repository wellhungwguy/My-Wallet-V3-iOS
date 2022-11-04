// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit
import FeatureStakingDomain
import NetworkKit

extension DependencyContainer {

    // MARK: - FeatureInterestData Module

    public static var featureStakingDataKit = module {

        single { () -> StakingAPIClient in
            StakingAPIClientProvider.provideClient(
                networkAdapter: DIKit.resolve(tag: DIKitContext.retail),
                requestBuilder: DIKit.resolve(tag: DIKitContext.retail)
            )
        }

        single { () -> StakingBalanceRepositoryAPI in
            let client: StakingAPIClient = DIKit.resolve()
            return StakingBalanceRepository(
                balanceProvider: client.getAllBalances
            )
        }
    }
}
