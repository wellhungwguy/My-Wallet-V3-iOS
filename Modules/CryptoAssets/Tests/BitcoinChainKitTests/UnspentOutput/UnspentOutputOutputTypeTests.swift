// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BigInt
@testable import BitcoinChainKit
import MoneyKit
import PlatformKit
import XCTest

final class BitcoinScriptTypeTests: XCTestCase {

    func testShouldReturnP2PKH() {
        XCTAssertEqual(UnspentOutput.createP2PKH().scriptType, .P2PKH)
        XCTAssertEqual(BitcoinScriptType(scriptData: Data(hex: "76a914641ad5051edd97029a003fe9efb29359fcee409d88ac")), .P2PKH)
    }

    func testShouldReturnP2WPKH() {
        XCTAssertEqual(UnspentOutput.createP2WPKH().scriptType, .P2WPKH)
        XCTAssertEqual(BitcoinScriptType(scriptData: Data(hex: "0014326e987644fa2d8ddf813ad40aa09b9b1229b71f")), .P2WPKH)
    }
}
