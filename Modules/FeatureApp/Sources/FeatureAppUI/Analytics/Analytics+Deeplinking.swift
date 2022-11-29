// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import AnalyticsKit
import Foundation

extension AnalyticsEvents.New {
    enum Deeplinking: AnalyticsEvent {
        var type: AnalyticsEventType { .nabu }

        case walletReferralProgramClicked(origin: String = "deeplink")
    }
}
