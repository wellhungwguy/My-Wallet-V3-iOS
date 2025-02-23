// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit
import FeatureStakingDomain
import NetworkKit

extension DependencyContainer {

    // MARK: - FeatureInterestData Module

    public static var featureStakingDataKit = module {

        single(tag: EarnProduct.savings) { () -> EarnClient in
            EarnClient(
                product: "savings",
                networkAdapter: DIKit.resolve(tag: DIKitContext.retail),
                requestBuilder: DIKit.resolve(tag: DIKitContext.retail)
            )
        }

        single(tag: EarnProduct.savings) { () -> EarnRepositoryAPI in
            EarnRepository(
                client: DIKit.resolve(tag: EarnProduct.savings)
            )
        }

        single(tag: EarnProduct.staking) { () -> EarnClient in
            EarnClient(
                product: "staking",
                networkAdapter: DIKit.resolve(tag: DIKitContext.retail),
                requestBuilder: DIKit.resolve(tag: DIKitContext.retail)
            )
        }

        single(tag: EarnProduct.staking) { () -> EarnRepositoryAPI in
            EarnRepository(
                client: DIKit.resolve(tag: EarnProduct.staking)
            )
        }
    }
}
