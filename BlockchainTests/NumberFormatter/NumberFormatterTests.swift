// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import XCTest

@testable import BlockchainApp
import PlatformKit

extension Locale {
    var safeDecimalSeparator: String {
        decimalSeparator ?? "."
    }
}

class NumberFormatterTests: XCTestCase {

    func testParseBitcoinValueFullStop() {
        let cases: [(String?, UInt64)] = [
            ("0", 0),
            (nil, 0),
            ("", 0),
            (".0", 0),
            ("0.0", 0),
            ("0.", 0),

            ("1", 100000000),
            ("1.", 100000000),
            (".1", 10000000),
            ("0.1", 10000000),

            ("12.01", 1201000000),
            ("10.12345678", 1012345678),
            ("123", 12300000000),
            ("123456789.12345678", 12345678912345678),

            ("123456789,12345678", 12345678912345678)
        ]
        for (idx, test) in cases.enumerated() {
            let result = NumberFormatter.parseBitcoinValue(from: test.0)
            XCTAssertEqual(
                test.1,
                NumberFormatter.parseBitcoinValue(from: test.0),
                "Failed #\(idx) - \(test.0 ?? "nil"): expected to be \(test.1) but got \(result) instead"
            )
        }
    }

    // Test conversion from arabic indic value for "10.123456789"
    func testArabicIndicDigitsDecimalString() {
        let arabicIndicValue = "\u{0661}\u{0660}\u{066B}\u{0661}\u{0662}\u{0663}\u{0664}\u{0665}\u{0666}\u{0667}\u{0668}\u{0669}"
        let converted = NumberFormatter.convert(decimalString: arabicIndicValue)
        XCTAssertEqual(converted, "10.123456789")
    }

    // Test conversion from "," delimiter
    func testCommaDelimitedDecimalString() {
        let arabicIndicValue = "10,123456789"
        let converted = NumberFormatter.convert(decimalString: arabicIndicValue)
        XCTAssertEqual(converted, "10.123456789")
    }
}
