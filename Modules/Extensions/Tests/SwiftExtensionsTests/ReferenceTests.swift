// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import ToolKit
import XCTest

final class ReferenceTests: XCTestCase {

    func test_reference() throws {

        func mutate(_ a: inout Struct, by value: String) {
            a.string = value
        }

        struct Struct { var string = "" }

        var a = Struct()
        let reference = Reference(&a)

        mutate(&reference.value, by: "Mutant")
        XCTAssertEqual(reference.value.string, "Mutant")
    }

    func test_weak() throws {

        class Object {}
        var value: Object? = Object()

        let weak = Weak(value)

        XCTAssertNotNil(weak.value)
        value = nil
        XCTAssertNil(weak.value)
    }
}
