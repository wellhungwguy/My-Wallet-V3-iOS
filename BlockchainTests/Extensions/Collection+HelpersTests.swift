// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation
import XCTest

@testable import BlockchainApp

class CollectionHelpersTests: XCTestCase {

    func testSafeIndexInBounds() {
        let array = [1, 2, 3, 4, 5]
        XCTAssertNotNil(array[safe: 0])
    }

    func testSafeIndexOutOfBounds() {
        let array = [1, 2, 3, 4, 5]
        XCTAssertNil(array[safe: 100])
    }
}
