// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import AsyncExtensions
import Combine
import CombineExtensions
import XCTest

final class PublisherCombineLatestTests: XCTestCase {

    func test_latest() async throws {
        let latest = try await (0...10).map(Just.init).combineLatest().await()
        XCTAssertEqual(latest, Array(0...10))
    }

    func test_updated_subject() async throws {

        let subjects = (0...10)
            .map(CurrentValueSubject<Int, Never>.init)

        for (i, subject) in subjects.enumerated() where i % 2 == 0 {
            subject.send(i * 2)
        }

        let a = try await subjects.combineLatest().await()
        XCTAssertEqual(a, [0, 1, 4, 3, 8, 5, 12, 7, 16, 9, 20])

        subjects.last?.send(100)
        let b = try await subjects.combineLatest().await()
        XCTAssertEqual(b, [0, 1, 4, 3, 8, 5, 12, 7, 16, 9, 100])
    }
}
