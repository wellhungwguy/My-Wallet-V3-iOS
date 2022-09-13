// Copyright © Blockchain Luxembourg S.A. All rights reserved.

@testable import CommonCryptoKit
import TestKit
import XCTest

class PBKDF2Tests: XCTestCase {

    func test_derivePBKDF2SHA1() throws {

        struct TestItem {
            let password: String
            let salt: [UInt8]
            let iterations: UInt32
            let keySizeBytes: UInt
            let expectedHex: String
        }

        func runTest(for item: TestItem) throws {
            let salt = Data(item.salt)
            let pw = item.password
            let iterations = item.iterations
            let expectedHex = item.expectedHex
            let keySizeBytes = item.keySizeBytes

            let result = try? PBKDF2.deriveSHA1Result(
                password: pw,
                salt: salt,
                iterations: iterations,
                keySizeBytes: keySizeBytes
            ).get()
            XCTAssertEqual(result!.hexValue, expectedHex)
        }

        let tests = [
            TestItem(
                password: "87082ca6c1ba65c00cc16bafab694af22311c10b8d2c2f5949ba3cd6cdb64534",
                salt: [
                    130,
                    149,
                    10,
                    103,
                    116,
                    223,
                    215,
                    231,
                    127,
                    212,
                    167,
                    158,
                    160,
                    201,
                    215,
                    157
                ],
                iterations: 1,
                keySizeBytes: 32,
                expectedHex: "447624b536f1197235e40cf4391c9eb57f08cdd00264047840e87d06ecbf9786"
            ),
            TestItem(
                password: "M6rv3L9JavGy3Si%PD5EHTKPz$E9N5",
                salt: [
                    194,
                    5,
                    155,
                    233,
                    171,
                    142,
                    26,
                    27,
                    227,
                    231,
                    183,
                    32,
                    77,
                    182,
                    133,
                    71
                ],
                iterations: 5000,
                keySizeBytes: 32,
                expectedHex: "78f7a3a3ec20d99b3ecc224e5c723c9b646962a1cec7b118006ac0822f5c5abf"
            )
        ]

        for item in tests {
            try runTest(for: item)
        }
    }

    func test_derivePBKDF2SHA512() throws {

        struct TestItem {
            let password: String
            let salt: [UInt8]
            let iterations: UInt32
            let keySizeBytes: UInt
            let expectedHex: String
        }

        func runTest(for item: TestItem) throws {
            let salt = Data(item.salt)
            let pw = item.password
            let iterations = item.iterations
            let expectedHex = item.expectedHex
            let keySizeBytes = item.keySizeBytes

            let result = PBKDF2.derive(
                password: pw,
                salt: salt,
                iterations: iterations,
                keySizeBytes: keySizeBytes,
                algorithm: .sha512
            )
            XCTAssertEqual(result!.hexValue, expectedHex)
        }

        let tests = [
            TestItem(
                password: "exercise loop fly noodle various century tooth remember relief castle entire high",
                salt: [
                    109,
                    110,
                    101,
                    109,
                    111,
                    110,
                    105,
                    99
                ],
                iterations: 2048,
                keySizeBytes: 64,
                expectedHex: "da91295d22b9fa6afe23d9567db5607d96d7df2c57eb2c13454de81f4eba1cab65dc07cd98a50a8e1e4195ed2679a287ee54878477fff5e8c17e1323cd68f6a1"
            )
        ]

        for item in tests {
            try runTest(for: item)
        }
    }
}
