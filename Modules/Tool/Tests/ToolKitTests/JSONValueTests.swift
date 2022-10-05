// Copyright © Blockchain Luxembourg S.A. All rights reserved.

@testable import ToolKit
import XCTest

final class JSONValueTests: XCTestCase {

    func testEncodableSupport() throws {
        let jsonData = Data(jsonString.utf8)

        // Test able to decode a JSONValue from the json data.
        let decodedFirstAttempt = try JSONDecoder().decode(JSONValue.self, from: jsonData)

        // Assert decoded value matches what we expect.
        XCTAssertEqual(decodedFirstAttempt, expectedResult)

        // Test able to encode a JSONValue.
        let encoded = try JSONEncoder().encode(decodedFirstAttempt)

        // Test able to decode a JSONValue from our encoded data.
        let decodedSecondAttempt = try JSONDecoder().decode(JSONValue.self, from: encoded)

        // Assert decoded value matches what we expect.
        XCTAssertEqual(decodedSecondAttempt, expectedResult)
    }
}

let jsonString: String = """
{
    "boolArray": [true, false],
    "emptyArray": [],
    "stringArray": ["one", "two"],
    "bool": true,
    "dictionary": {
        "boolArray": [true, false],
        "emptyArray": [],
        "stringArray": ["one", "two"],
        "bool": true,
        "null": null,
        "number1": 1,
        "number2.2": 2.2,
        "string": "one"
    },
    "null": null,
    "number1": 1,
    "number2.2": 2.2,
    "string": "one"
}
"""

let expectedResult: JSONValue = .dictionary([
    "boolArray": .array([.bool(true), .bool(false)]),
    "emptyArray": .array([]),
    "stringArray": .array([.string("one"), .string("two")]),
    "bool": .bool(true),
    "dictionary": .dictionary([
        "boolArray": .array([.bool(true), .bool(false)]),
        "emptyArray": .array([]),
        "stringArray": .array([.string("one"), .string("two")]),
        "bool": .bool(true),
        "null": .null,
        "number1": .number(1),
        "number2.2": .number(2.2),
        "string": .string("one")
    ]),
    "null": .null,
    "number1": .number(1),
    "number2.2": .number(2.2),
    "string": .string("one")
])
