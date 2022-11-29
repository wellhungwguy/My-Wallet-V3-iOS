// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import AnalyticsKit

extension AnalyticsEvents.New {
    enum Support: AnalyticsEvent {
        case contactUsClicked
        case viewFAQsClicked
        case customerSupportClicked

        var type: AnalyticsEventType { .nabu }
    }
}

extension AnalyticsEventRecorderAPI {
    func record(event: AnalyticsEvents.New.Support) {
        record(event: event)
    }
}
