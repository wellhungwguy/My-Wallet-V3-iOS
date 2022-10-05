// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit
import FeatureAppUI
import FeatureKYCUI
import FeatureSettingsDomain
import FeatureSettingsUI
import PlatformUIKit
import WalletPayloadKit

// MARK: - Blockchain Module

extension DependencyContainer {

    static var blockchainSettings = module {

        single { () -> FeatureSettingsDomain.KeychainItemWrapping in
            KeychainItemSwiftWrapper()
        }

        factory { () -> FeatureSettingsUI.ExternalActionsProviderAPI in
            let bridge: LoggedInDependencyBridgeAPI = DIKit.resolve()
            return bridge.resolveExternalActionsProvider() as ExternalActionsProviderAPI
        }

        factory { () -> FeatureSettingsUI.KYCRouterAPI in
            KYCAdapter()
        }

        factory { () -> FeatureSettingsUI.PaymentMethodsLinkerAPI in
            PaymentMethodsLinkingAdapter()
        }

        factory { () -> FeatureSettingsUI.AuthenticationCoordinating in
            let bridge: LoggedInDependencyBridgeAPI = DIKit.resolve()
            return bridge.resolveAuthenticationCoordinating() as AuthenticationCoordinating
        }
    }
}
