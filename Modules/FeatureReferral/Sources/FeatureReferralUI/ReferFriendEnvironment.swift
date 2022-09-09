// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import AnalyticsKit
import ComposableArchitecture
import DIKit
import Foundation

public struct ReferFriendEnvironment {
    public let mainQueue: AnySchedulerOf<DispatchQueue>
    public let analyticsRecorder: AnalyticsEventRecorderAPI

    public init(
        mainQueue: AnySchedulerOf<DispatchQueue>,
        analyticsRecorder: AnalyticsEventRecorderAPI = resolve()
    ) {
        self.mainQueue = mainQueue
        self.analyticsRecorder = analyticsRecorder
    }
}
