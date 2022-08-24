// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import ToolKit
import XCTest

final class OptionalTests: XCTestCase {

    func test_or_throw() throws {
        enum Test: Error { case error }

        var value: String? = "string"
        XCTAssertNoThrow(try value.or(throw: Test.error))

        value = nil
        XCTAssertThrowsError(try value.or(throw: Test.error))
    }
}
