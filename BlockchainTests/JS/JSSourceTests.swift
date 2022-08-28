// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainApp
import ToolKit
import XCTest

class JSSourceTests: XCTestCase {

    func testMyWalletSourceIsPresent() {
        let path = MainBundleProvider.mainBundle.path(forResource: "my-wallet", ofType: "js")
        XCTAssertNotNil(path)
    }

    func testWalletIOSSourceIsPresent() {
        let path = MainBundleProvider.mainBundle.path(forResource: "wallet-ios", ofType: "js")
        XCTAssertNotNil(path)
    }
}
