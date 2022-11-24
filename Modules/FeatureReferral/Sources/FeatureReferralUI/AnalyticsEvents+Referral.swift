// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import AnalyticsKit
import Foundation

extension AnalyticsEvents.New {
    enum Referral: AnalyticsEvent, Equatable {
        var type: AnalyticsEventType { .nabu }

        case viewReferralsPage(campaign_id: String)
        case shareReferralsCode(campaign_id: String)
        case referralCodeCopied(campaign_id: String)
    }
}
