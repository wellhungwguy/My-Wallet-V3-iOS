// Copyright © Blockchain Luxembourg S.A. All rights reserved.

@testable import HDWalletKit
import XCTest

class HDKeyPathTests: XCTestCase {

    func test_parse_keyPath_success() throws {

        struct TestCase {
            let input: String
            let output: Result<HDKeyPath, HDKeyPathError>
        }

        let testCases = [
            TestCase(
                input: "m",
                output: .success(
                    HDKeyPath(components: [])
                )
            ),
            TestCase(
                input: "m/0",
                output: .success(
                    HDKeyPath(components: [
                        .normal(0)
                    ])
                )
            ),
            TestCase(
                input: "m/0'/",
                output: .success(
                    HDKeyPath(components: [
                        .hardened(0)
                    ])
                )
            ),
            TestCase(
                input: "M/0h/1",
                output: .success(
                    HDKeyPath(components: [
                        .hardened(0),
                        .normal(1)
                    ])
                )
            ),
            TestCase(
                input: "M/0/1H",
                output: .success(
                    HDKeyPath(components: [
                        .normal(0),
                        .hardened(1)
                    ])
                )
            ),
            TestCase(
                input: "m/0'/1/2'/2/1000000000/",
                output: .success(
                    HDKeyPath(components: [
                        .hardened(0),
                        .normal(1),
                        .hardened(2),
                        .normal(2),
                        .normal(1000000000)
                    ])
                )
            ),
            TestCase(
                input: "M/0/2147483647'/1/2147483646'/2",
                output: .success(
                    HDKeyPath(components: [
                        .normal(0),
                        .hardened(2147483647),
                        .normal(1),
                        .hardened(2147483646),
                        .normal(2)
                    ])
                )
            )
        ]

        for testCase in testCases {
            let result = HDKeyPath.from(string: testCase.input)
            XCTAssertEqual(result, testCase.output)

            if let keyPath = try? result.get() {
                XCTAssertEqual(
                    keyPath.description,
                    normaliseInput(testCase.input)
                )
            }
        }
    }

    func test_parse_keyPath_failure() throws {

        let testCases = [
            "M/0/21474836470'/1/'/2",
            "m/0/5'1/'1/2",
            "/0/5'/1/'1/2",
            "m/0/5'/1''/'1/2",
            "m/0/5'/1hh/'1/2"
        ]

        for testCase in testCases {
            XCTAssertThrowsError(try HDKeyPath.from(string: testCase).get())
        }
    }
}

private func normaliseInput(_ input: String) -> String {
    var input = input
        .replacingOccurrences(of: "h", with: "'")
        .replacingOccurrences(of: "H", with: "'")
        .replacingOccurrences(of: "M", with: "m")
        .lowercased()
    guard input.last == "/" else {
        return input
    }
    input.removeLast()
    return input
}
