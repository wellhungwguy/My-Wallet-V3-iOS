// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import ToolKit
import XCTest

final class PublisherZipTests: XCTestCase {

    var result: [Int]?
    var bag: Set<AnyCancellable> = []

    func test_zip() throws {
        let latest = try (0...10).map(Just.init).zip().wait()
        XCTAssertEqual(latest, Array(0...10))
    }

    func test_zip_updated_subject() throws {

        let subjects = (0...10)
            .map { _ in PassthroughSubject<Int, Never>() }

        subjects.zip()
            .assign(to: \.result, on: self)
            .store(in: &bag)

        for (i, subject) in subjects.dropFirst().enumerated() {
            subject.send(i + 1)
        }

        XCTAssertNil(result)

        subjects[0].send(100)
        XCTAssertEqual(result, [100, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10])
    }
}
