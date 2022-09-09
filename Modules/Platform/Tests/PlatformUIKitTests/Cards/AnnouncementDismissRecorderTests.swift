// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import XCTest

@testable import PlatformKit
@testable import PlatformUIKit
@testable import PlatformUIKitMock
@testable import ToolKit
@testable import ToolKitMock

extension AnnouncementRecord.DisplayState {
    var isHidden: Bool {
        switch self {
        case .show, .conditional:
            return false
        case .hide:
            return true
        }
    }

    var isShown: Bool {
        switch self {
        case .hide, .conditional:
            return false
        case .show:
            return true
        }
    }

    var isConditional: Bool {
        switch self {
        case .conditional:
            return true
        case .show, .hide:
            return false
        }
    }
}

final class AnnouncementRecorderTests: XCTestCase {

    private var cache: MemoryCacheSuite!
    private var dismissRecorder: AnnouncementRecorder!
    private var entry: AnnouncementRecorder.Entry!
    private let key = AnnouncementRecord.Key.applePay

    override func setUp() {
        super.setUp()
        cache = MemoryCacheSuite()
        dismissRecorder = AnnouncementRecorder(cache: cache, errorRecorder: MockErrorRecorder())
        entry = dismissRecorder[key]
    }

    func testOnTimeRecordIsDismissedInCacheSuite() {
        XCTAssertTrue(entry.displayState.isShown)
        entry.markDismissed(category: .oneTime)
        XCTAssertTrue(entry.displayState.isHidden)
    }

    func testPeriodicRecordIsDismissedInCacheSuite() {
        XCTAssertTrue(entry.displayState.isShown)
        entry.markDismissed(category: .periodic)
        XCTAssertTrue(entry.displayState.isConditional)
    }
}

final class AnnouncementTests: XCTestCase {
    func testAnnouncementQueue() {
        let cache = MemoryCacheSuite()
        let oneTimeAnnouncements = [
            MockOneTimeAnnouncement(type: .applePay, cacheSuite: cache, dismiss: {}),
            MockOneTimeAnnouncement(type: .resubmitDocuments, cacheSuite: cache, dismiss: {})
        ]
        oneTimeAnnouncements[1].markRemoved()
        XCTAssertFalse(oneTimeAnnouncements[0].isDismissed)
        XCTAssertTrue(oneTimeAnnouncements[1].isDismissed)
    }
}
