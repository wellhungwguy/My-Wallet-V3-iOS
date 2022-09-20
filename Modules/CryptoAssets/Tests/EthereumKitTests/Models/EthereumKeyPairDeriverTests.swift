// Copyright © Blockchain Luxembourg S.A. All rights reserved.

@testable import EthereumKit
@testable import EthereumKitMock
import XCTest

final class EthereumKeyPairDeriverTests: XCTestCase {

    var subject: EthereumKeyPairDeriver!

    override func setUp() {
        super.setUp()
        subject = EthereumKeyPairDeriver()
    }

    override func tearDown() {
        subject = nil
        super.tearDown()
    }

    func test_derive() {
        // Arrange
        let expectedKeyPair = MockEthereumWalletTestData.keyPair

        let keyDerivationInput = EthereumKeyDerivationInput(
            mnemonic: MockEthereumWalletTestData.mnemonic
        )

        // Act
        guard case .success(let result) = subject.derive(input: keyDerivationInput) else {
            XCTFail("The transaction should be built successfully")
            return
        }

        // Assert
        XCTAssertEqual(result, expectedKeyPair)
        // Assert private key hex  match
        XCTAssertEqual(result.privateKey.data.hexString, expectedKeyPair.privateKey.data.hexString)
    }
}
