// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit
import FeatureAddressSearchDomain
import UIKit
import UIKitExtensions

extension DependencyContainer {

    // MARK: - FeatureAddressSearch Module

    public static var featureAddressSearchUI = module {

        factory {
            AddressSearchRouter(
                topMostViewControllerProvider: DIKit.resolve()
            ) as AddressSearchRouterAPI
        }
    }
}
