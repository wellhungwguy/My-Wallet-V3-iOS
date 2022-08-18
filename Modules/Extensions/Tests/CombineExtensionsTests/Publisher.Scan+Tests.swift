// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import ToolKit
import XCTest

final class PublisherScanTests: XCTestCase {

    var bag: Set<AnyCancellable> = []
    var value: (newValue: Int, oldValue: Int)?

    func test_scan() throws {
        let subject = CurrentValueSubject<Int, Never>(0)

        subject.scan()
            .assign(to: \.value, on: self)
            .store(in: &bag)

        XCTAssertNil(value)

        subject.send(1)

        XCTAssertEqual(value?.newValue, 1)
        XCTAssertEqual(value?.oldValue, 0)

        subject.send(2)

        XCTAssertEqual(value?.newValue, 2)
        XCTAssertEqual(value?.oldValue, 1)
    }

    var values: [Int]?

    func test_scan_count() throws {

        let subject = CurrentValueSubject<Int, Never>(0)

        subject.scan(count: 3)
            .assign(to: \.values, on: self)
            .store(in: &bag)

        XCTAssertNil(values)

        subject.send(1)
        XCTAssertNil(values)

        subject.send(2)
        XCTAssertEqual(values, [0, 1, 2])

        subject.send(3)
        XCTAssertEqual(values, [1, 2, 3])
    }
}
