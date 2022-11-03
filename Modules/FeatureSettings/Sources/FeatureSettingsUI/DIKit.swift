// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit
import FeatureSettingsDomain

extension DependencyContainer {

    public static var featureSettingsUI = module {

        single { () -> SettingsRouterAPI in
            SettingsRouter(
                exchangeUrlProvider: exchangeUrlProvider
            )
        }
    }
}
