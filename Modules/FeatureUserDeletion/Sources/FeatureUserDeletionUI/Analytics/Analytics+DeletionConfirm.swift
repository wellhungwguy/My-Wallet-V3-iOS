// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import AnalyticsKit

extension AnalyticsEvents.New {
    enum DeletionConfirm: AnalyticsEvent {
        case accountDeletionSuccess
        case accountDeletionFailure(errorMessage: String)

        var type: AnalyticsEventType { .nabu }
    }
}

extension AnalyticsEventRecorderAPI {
    func record(event: AnalyticsEvents.New.DeletionConfirm) {
        record(event: event)
    }
}
