// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit
import FeatureAppUI
import FeatureDashboardUI
import FeatureKYCUI
import FeatureSettingsDomain
import FeatureSettingsUI
import PlatformUIKit
import RxCocoa
import WalletPayloadKit

// MARK: - Blockchain Module

extension DependencyContainer {

    static var blockchainDashboard = module {

        factory { () -> FeatureDashboardUI.WalletOperationsRouting in
            let bridge: LoggedInDependencyBridgeAPI = DIKit.resolve()
            return bridge.resolveWalletOperationsRouting() as FeatureDashboardUI.WalletOperationsRouting
        }

        factory { AnnouncementPresenter() as FeatureDashboardUI.AnnouncementPresenting }

        factory { AnalyticsUserPropertyInteractor() as FeatureDashboardUI.AnalyticsUserPropertyInteracting }
    }
}

extension AnalyticsUserPropertyInteractor: FeatureDashboardUI.AnalyticsUserPropertyInteracting {}

extension AnnouncementPresenter: FeatureDashboardUI.AnnouncementPresenting {}
