// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit
import Foundation
import ToolKit

extension DependencyContainer {

    public static var featureAddressSearchDomain = module {

        factory {
            AddressSearchService(
                repository: DIKit.resolve()
            ) as AddressSearchServiceAPI
        }
    }
}
