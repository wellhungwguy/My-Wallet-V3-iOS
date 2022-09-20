// Copyright © Blockchain Luxembourg S.A. All rights reserved.

@testable import WalletPayloadDataKit
@testable import WalletPayloadKit

import Combine
import TestKit
import ToolKit
import XCTest

class HDWalletTests: XCTestCase {

    func test_can_create_an_hd_wallet_from_mnemonic() {
        let mnemonic = "abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon about"

        let hdWalletResult = generateHDWallet(mnemonic: mnemonic, accountName: "account name", totalAccounts: 1)

        let expectedSeedHex = "00000000000000000000000000000000"

        let expectedAccounts = [
            Account(
                index: 0,
                label: "account name",
                archived: false,
                defaultDerivation: .segwit,
                derivations: [
                    Derivation(
                        type: .legacy,
                        purpose: DerivationType.legacy.purpose,
                        xpriv: "xprv9xpXFhFpqdQK3TmytPBqXtGSwS3DLjojFhTGht8gwAAii8py5X6pxeBnQ6ehJiyJ6nDjWGJfZ95WxByFXVkDxHXrqu53WCRGypk2ttuqncb",
                        xpub: "xpub6BosfCnifzxcFwrSzQiqu2DBVTshkCXacvNsWGYJVVhhawA7d4R5WSWGFNbi8Aw6ZRc1brxMyWMzG3DSSSSoekkudhUd9yLb6qx39T9nMdj",
                        addressLabels: [],
                        cache: AddressCache(
                            receiveAccount: "xpub6ELHKXNs6z8vXa6XbGJZvX8cJ7sSHG9HsSLEKDDy79VVjEeBJwHBomMMjVcZZxdKd1Xv24ikajY6rTEirQadVWoyctw1tfV8wV3FNDKY4rD",
                            changeAccount: "xpub6ELHKXNs6z8vZcESyLipftAuxo5Q51z8twf5J2GNDMEVuiSLf5CR2DF94F7425dBbd8NVGy8sx6s62edGqiAmt6LmiDVjVwuWocm2nggSdQ"
                        )
                    ),
                    Derivation(
                        type: .segwit,
                        purpose: DerivationType.segwit.purpose,
                        xpriv: "xprv9ybY78BftS5UGANki6oSifuQEjkpyAC8ZmBvBNTshQnCBcxnefjHS7buPMkkqhcRzmoGZ5bokx7GuyDAiktd5HemohAU4wV1ZPMDRmLpBMm",
                        xpub: "xpub6CatWdiZiodmUeTDp8LT5or8nmbKNcuyvz7WyksVFkKB4RHwCD3XyuvPEbvqAQY3rAPshWcMLoP2fMFMKHPJ4ZeZXYVUhLv1VMrjPC7PW6V",
                        addressLabels: [],
                        cache: AddressCache(
                            receiveAccount: "xpub6FPnz8nmUypv2k1tV1EdhXJ8FLeQZCMJmUxozcTCyRSoPW7xuYnMyTJ5VrmfS9fTBAViJ6HBrGMyRTWrTDxwKq8Gx1RMNEK7D3g8yHeDPHU",
                            changeAccount: "xpub6FPnz8nmUypv56G7VP2zdPtyru9LKPBvLE6LeP8QKkyCGtDad6TqLoTJzg6GvnLt5VvTZHBvEuKE7Mnc6HSsGy1fLPL6skU7FMnH61qqNW2"
                        )
                    )
                ]
            )
        ]

        switch hdWalletResult {
        case .success(let hdWallet):
            XCTAssertFalse(hdWallet.mnemonicVerified)
            XCTAssertEqual(hdWallet.seedHex, expectedSeedHex)
            XCTAssertEqual(hdWallet.passphrase, "")
            XCTAssertEqual(hdWallet.defaultAccountIndex, 0)
            XCTAssertFalse(hdWallet.accounts.isEmpty)
            XCTAssertEqual(hdWallet.accounts, expectedAccounts)
            return
        case .failure:
            XCTFail("should provide an hd wallet")
        }
    }
}

// swiftlint:enable line_length
