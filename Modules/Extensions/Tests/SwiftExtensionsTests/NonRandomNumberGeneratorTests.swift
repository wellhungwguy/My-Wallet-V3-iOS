// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import ToolKit
import XCTest

final class NonRandomNumberGeneratorTests: XCTestCase {

    func test() throws {

        var randomNumberGenerator = NonRandomNumberGenerator([1, 2, 3, 4, 5])

        XCTAssertEqual(randomNumberGenerator.next(), 1)
        XCTAssertEqual(randomNumberGenerator.next(), 2)
        XCTAssertEqual(randomNumberGenerator.next(), 3)
        XCTAssertEqual(randomNumberGenerator.next(), 4)
        XCTAssertEqual(randomNumberGenerator.next(), 5)
        XCTAssertEqual(randomNumberGenerator.next(), 1)
    }
}
