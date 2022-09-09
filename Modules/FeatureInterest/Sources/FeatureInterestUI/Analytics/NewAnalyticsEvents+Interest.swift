// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import AnalyticsKit

extension AnalyticsEvents.New {
    enum InterestAnalyticsEvent: AnalyticsEvent {

        var type: AnalyticsEventType { .nabu }

        case interestViewed
        case walletRewardsDetailClicked(currency: String)
        case walletRewardsDetailViewed(currency: String)

        case walletRewardsDetailDepositClicked(currency: String)

        case interestWithdrawalClicked(currency: String)
        case interestDepositClicked(currency: String)
    }
}

extension AnalyticsEventRecorderAPI {
    func record(event: AnalyticsEvents.New.InterestAnalyticsEvent) {
        record(event: event)
    }
}
