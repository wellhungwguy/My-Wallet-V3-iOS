// Copyright © Blockchain Luxembourg S.A. All rights reserved.

@testable import EthereumKit
@testable import EthereumKitMock

import WalletCore
import XCTest

class EthereumAddressProviderTests: XCTestCase {

    func test_can_private_correct_eth_address() {
        // given
        let mnemonic = "business envelope ride merry time drink chat cinnamon hamster left spend gather"
        let hdWallet = WalletCore.HDWallet(mnemonic: mnemonic, passphrase: "")

        guard let hdWallet else {
            XCTFail("couldn't not create HDWallet")
            return
        }

        // when
        let key = generatePrivateKey(hdWallet: hdWallet, accountIndex: 0)

        // then
        let address = generateEthereumAddress(privateKey: key)
        XCTAssertEqual(
            address,
            "0x446335ca6156Fe66e610e7C47e8678cAc5a7a98A"
        )
    }
}
