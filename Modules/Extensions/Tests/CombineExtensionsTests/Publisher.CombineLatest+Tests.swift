// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import ToolKit
import XCTest

final class PublisherCombineLatestTests: XCTestCase {

    func test_latest() throws {
        let latest = try (0...10).map(Just.init).combineLatest().wait()
        XCTAssertEqual(latest, Array(0...10))
    }

    func test_updated_subject() throws {

        let subjects = (0...10)
            .map(CurrentValueSubject<Int, Never>.init)

        for (i, subject) in subjects.enumerated() where i % 2 == 0 {
            subject.send(i * 2)
        }

        try XCTAssertEqual(subjects.combineLatest().wait(), [0, 1, 4, 3, 8, 5, 12, 7, 16, 9, 20])

        subjects.last?.send(100)
        try XCTAssertEqual(subjects.combineLatest().wait(), [0, 1, 4, 3, 8, 5, 12, 7, 16, 9, 100])
    }
}
