// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import ToolKit
import XCTest

final class PublisherShareReplayTests: XCTestCase {

    var bag: Set<AnyCancellable> = []

    func test_share_replay() throws {

        let subject = CurrentValueSubject<Int, Never>(1)
        let publisher = subject.shareReplay()

        do {
            var results = [Int]()

            publisher
                .sink { results.append($0) }
                .store(in: &bag)

            subject.send(2)

            XCTAssertEqual(results, [1, 2])
        }

        do {
            var results = [Int]()

            publisher
                .sink { results.append($0) }
                .store(in: &bag)

            XCTAssertEqual(results, [2])
        }
    }
}
