// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation
import PlatformKit
import ToolKit
import XCTest

@testable import BlockchainApp

final class AnnouncementTests: XCTestCase {

    // MARK: CloudBackup

    func testCloudBackupAnnouncementShows() {
        let cache = MemoryCacheSuite()
        let announcement = CloudBackupAnnouncement(
            cacheSuite: cache,
            dismiss: {},
            action: {}
        )
        XCTAssertTrue(announcement.shouldShow)
        XCTAssertFalse(announcement.isDismissed)

        announcement.markRemoved()

        XCTAssertFalse(announcement.shouldShow)
        XCTAssertTrue(announcement.isDismissed)
    }
}
