// Copyright © Blockchain Luxembourg S.A. All rights reserved.

@testable import MoneyKit
import XCTest

final class SupportedAssetsFilePathProviderTests: XCTestCase {

    var sut: SupportedAssetsFilePathProviderAPI!

    override func setUp() {
        super.setUp()
        sut = SupportedAssetsFilePathProvider()
    }

    override func tearDown() {
        super.tearDown()
        sut = nil
    }

    func testLocalEthereumERC20FileIsPresent() {
        guard let localFile = sut.localEthereumERC20Assets else {
            XCTFail("Missing local file.")
            return
        }
        XCTAssertTrue(localFile.absoluteString.contains("local-currencies-ethereum-erc20.json"))
        XCTAssertTrue(FileManager.default.fileExists(atPath: localFile.relativePath))
    }

    func testLocalOtherERC20FileIsPresent() {
        guard let localFile = sut.localOtherERC20Assets else {
            XCTFail("Missing local file.")
            return
        }
        XCTAssertTrue(localFile.absoluteString.contains("local-currencies-other-erc20.json"))
        XCTAssertTrue(FileManager.default.fileExists(atPath: localFile.relativePath))
    }

    func testLocalCustodialFileIsPresent() {
        guard let localFile = sut.localCustodialAssets else {
            XCTFail("Missing local file.")
            return
        }
        XCTAssertTrue(localFile.absoluteString.contains("local-currencies-custodial.json"))
        XCTAssertTrue(FileManager.default.fileExists(atPath: localFile.relativePath))
    }
}
