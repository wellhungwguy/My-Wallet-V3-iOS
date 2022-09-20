// Copyright © Blockchain Luxembourg S.A. All rights reserved.

@testable import BitcoinChainKit
import MoneyKit
import WalletCore
import XCTest

final class GetWalletKeyPairsTests: XCTestCase {

    func test_getWalletKeyPairs() throws {
        let account = BitcoinChainAccount(index: 0, coin: .bitcoin)
        let mnemonic = "abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon about"
        let xpub44 = "xpub6BosfCnifzxcFwrSzQiqu2DBVTshkCXacvNsWGYJVVhhawA7d4R5WSWGFNbi8Aw6ZRc1brxMyWMzG3DSSSSoekkudhUd9yLb6qx39T9nMdj"
        let xpub84 = "xpub6CatWdiZiodmUeTDp8LT5or8nmbKNcuyvz7WyksVFkKB4RHwCD3XyuvPEbvqAQY3rAPshWcMLoP2fMFMKHPJ4ZeZXYVUhLv1VMrjPC7PW6V"
        let accountKeyContext = getAccountKeyContext(
            for: account,
            mnemonic: Mnemonic(words: mnemonic)
        )
        let result = getWalletKeyPairs(
            unspentOutputs: [
                UnspentOutput.createP2PKH(m: xpub44, path: "M/0/0"),
                UnspentOutput.createP2WPKH(m: xpub84, path: "M/1/0")
            ],
            accountKeyContext: accountKeyContext
        )

        let expected: [WalletKeyPair] = [
            WalletKeyPair(
                xpriv: "xprv9xpXFhFpqdQK3TmytPBqXtGSwS3DLjojFhTGht8gwAAii8py5X6pxeBnQ6ehJiyJ6nDjWGJfZ95WxByFXVkDxHXrqu53WCRGypk2ttuqncb",
                privateKeyData: Data(hex: "e284129cc0922579a535bbf4d1a3b25773090d28c909bc0fed73b5e0222cc372"),
                xpub: XPub(
                    address: xpub44,
                    derivationType: .legacy
                )
            ),
            WalletKeyPair(
                xpriv: "xprv9ybY78BftS5UGANki6oSifuQEjkpyAC8ZmBvBNTshQnCBcxnefjHS7buPMkkqhcRzmoGZ5bokx7GuyDAiktd5HemohAU4wV1ZPMDRmLpBMm",
                privateKeyData: Data(hex: "3277578a56b721e4c9f071f1e24aa0f94c4ff72e7967fea03b134f605f07c8fd"),
                xpub: XPub(
                    address: xpub84,
                    derivationType: .bech32
                )
            )
        ]

        XCTAssertEqual(result, expected)
    }

    func test_unspentOutput_derivation_path() throws {

        let testCases: [(String, [WalletCore.DerivationPath.Index])] = [
            ("M/0/0", [.init(0, hardened: false), .init(0, hardened: false)]),
            ("M/0/8", [.init(0, hardened: false), .init(8, hardened: false)]),
            ("0/0", [.init(0, hardened: false), .init(0, hardened: false)]),
            ("0/8", [.init(0, hardened: false), .init(8, hardened: false)])
        ]

        for (path, expected) in testCases {
            let utxo = UnspentOutput.createP2WPKH(path: path)
            let result = try derivationPathComponents(for: utxo).get()
            XCTAssertEqual(result, expected)
        }
    }
}
