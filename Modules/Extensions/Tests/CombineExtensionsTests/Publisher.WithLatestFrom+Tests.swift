// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import ToolKit
import XCTest

final class PublisherWithLatestFromTests: XCTestCase {

    var string: String?
    var bag: Set<AnyCancellable> = []

    func test_with_latest_from() throws {

        let trigger = PassthroughSubject<Void, Never>()
        let subject = CurrentValueSubject<String, Never>("Hello World!")

        trigger
            .withLatestFrom(subject)
            .assign(to: \.string, on: self)
            .store(in: &bag)

        XCTAssertNil(string)

        trigger.send(())
        XCTAssertEqual(string, "Hello World!")

        subject.send("Dorothy Gale")
        XCTAssertEqual(string, "Hello World!")

        trigger.send(())
        XCTAssertEqual(string, "Dorothy Gale")
    }
}
