// Copyright © Blockchain Luxembourg S.A. All rights reserved.

@testable import EthereumKit
@testable import EthereumKitMock
import XCTest

class EthereumAddressTests: XCTestCase {

    func test_address_validation_fails_for_truncated_address() {
        var address = MockEthereumWalletTestData.account
        address.removeLast()

        XCTAssertNil(EthereumAddress(address: address, network: .ethereum))

        XCTAssertThrowsError(try EthereumAddress(string: address, network: .ethereum)) { error in
            XCTAssertEqual(error as? AddressValidationError, .invalidLength)
        }
    }

    func test_address_validation_fails_for_invalid_characters_in_address() {
        // Sanity check
        XCTAssertTrue(MockEthereumWalletTestData.account.contains("e"))
        let invalidAddresses = ["😈", "&", "^", "󌞑"].map { invalidComponent -> String in
            MockEthereumWalletTestData.account.replacingOccurrences(of: "e", with: invalidComponent)
        }

        for address in invalidAddresses {
            XCTAssertNil(EthereumAddress(address: address, network: .ethereum))
            XCTAssertThrowsError(try EthereumAddress(string: address, network: .ethereum)) { error in
                XCTAssertEqual(error as? AddressValidationError, .containsInvalidCharacters)
            }
        }
    }

    func test_address_validation_succeeds_for_prefixed_address() {
        let address = "ethereum:0x829B325036EE8F6B6ec80311d2699505505696eF"
        XCTAssertNotNil(try EthereumAddress(string: address.removing(prefix: "ethereum:"), network: .ethereum))
    }

    func test_address_validation_succeeds_for_non_prefixed_address() {
        let address = "0x829B325036EE8F6B6ec80311d2699505505696eF"
        XCTAssertNotNil(try EthereumAddress(string: address.removing(prefix: "ethereum:"), network: .ethereum))
    }

    func test_address_validation_fails_for_invalid_length() {
        // Sanity check
        XCTAssertTrue(MockEthereumWalletTestData.account.contains("e"))
        let invalidAddresses = ["𝚨", "ee"].map { invalidComponent -> String in
            MockEthereumWalletTestData.account.replacingOccurrences(of: "e", with: invalidComponent)
        }

        for address in invalidAddresses {
            XCTAssertNil(EthereumAddress(address: address, network: .ethereum))
            XCTAssertThrowsError(try EthereumAddress(string: address, network: .ethereum)) { error in
                XCTAssertEqual(error as? AddressValidationError, .invalidLength)
            }
        }
    }
}
