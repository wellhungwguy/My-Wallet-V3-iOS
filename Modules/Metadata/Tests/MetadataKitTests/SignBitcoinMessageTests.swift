// Copyright © Blockchain Luxembourg S.A. All rights reserved.

@testable import MetadataHDWalletKit
@testable import MetadataKit
import XCTest

final class SignBitcoinMessageTests: XCTestCase {

    func testSignMessage() throws {

        let environment = TestEnvironment()

        let expectedSignedMessage = "IL0qb9G5GkC19oYNPNjbMtC7lZlGpC/RMnf3htVkgvZSE/JfaFhwspJ1tZOBqHZMjNWOcf/DaQomztmGrZUzkjc="

        let message: [UInt8] =
            Data(
                base64Encoded: "9mHB0U2OWGwHtGo+nC7NZh5h08hq502Vqed3Dv0KCkkiaxrBLyBzteYew9CDWIVT5XzWt1ZeUJdQoq2/zcTUww=="
            )!
            .bytes
        let secondPasswordNode = environment.secondPasswordNode

        let signedMessage = try
            sign(
                bitcoinMessage: message,
                with: secondPasswordNode.metadataNode
            )
            .get()

        XCTAssertEqual(signedMessage, expectedSignedMessage)
    }
}
