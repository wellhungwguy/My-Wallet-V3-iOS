// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import RxSwift
import XCTest

@testable import AnalyticsKit
@testable import BlockchainNamespace
#if canImport(AnalyticsKitMock)
@testable import AnalyticsKitMock
#endif
@testable import PlatformKit
@testable import PlatformUIKit
@testable import ToolKit
#if canImport(ToolKitMock)
@testable import ToolKitMock
#endif

struct MockOneTimeAnnouncement: OneTimeAnnouncement {

    var viewModel: AnnouncementCardViewModel {
        fatalError("\(#function) was not implemented")
    }

    var associatedAppModes: [AppMode] = [.universal, .trading]

    var shouldShow: Bool {
        !isDismissed
    }

    let dismiss: CardAnnouncementAction
    let recorder: AnnouncementRecorder
    let type: AnnouncementType
    let analyticsRecorder: AnalyticsEventRecorderAPI

    init(
        type: AnnouncementType,
        cacheSuite: CacheSuite,
        analyticsRecorder: AnalyticsEventRecorderAPI = AnalyticsEventRecorder(
            analyticsServiceProviders: [MockAnalyticsService()]
        ),
        dismiss: @escaping CardAnnouncementAction
    ) {
        self.type = type
        self.recorder = AnnouncementRecorder(cache: cacheSuite, errorRecorder: MockErrorRecorder())
        self.analyticsRecorder = analyticsRecorder
        self.dismiss = dismiss
    }
}
