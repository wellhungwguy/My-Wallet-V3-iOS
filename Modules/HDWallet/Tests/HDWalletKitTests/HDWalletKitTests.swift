// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import CommonCryptoKit
@testable import HDWalletKit
import XCTest

class HDWalletKitTests: XCTestCase {

    func test_hd_wallet() throws {

        XCTSkip()

        //        // Test Mnemonic
        //
        //        let allWords = [
        //            "abandon",
        //            "abandon",
        //            "abandon",
        //            "abandon",
        //            "abandon",
        //            "abandon",
        //            "abandon",
        //            "abandon",
        //            "abandon",
        //            "abandon",
        //            "abandon",
        //            "about"
        //        ]
        //
        //        let words = try Words(words: allWords)
        //
        //        let passphrase = Passphrase(rawValue: "TREZOR")
        //
        //        let mnemonic = try Mnemonic(words: words, passphrase: passphrase)
        //
        //        let seed = mnemonic.seed!
        //        let expectedSeed = "c55257c360c07c72029aebc1b53c05ed0362ada38ead3e3e9efa3708e53495531f09a6987599d18264c1e1c92f2cf141630c7a3c4ab7c81b2f001698e7463b04"
        //
        //        XCTAssertEqual(expectedSeed, seed.description)
        //
        //        // Test Private Key
        //
        //        let privateKey = try HDPrivateKey(seed: seed, network: .main(Bitcoin.self))
        //
        //        XCTAssertEqual(privateKey.publicKey, HDPublicKey("02f632717d78bf73e74aa8461e2e782532abae4eed5110241025afb59ebfd3d2fd")!)
        //        XCTAssertEqual(privateKey.xpub, "xpub661MyMwAqRbcGB88KaFbLGiYAat55APKhtWg4uYMkXAmfuSTbq2QYsn9sKJCj1YqZPafsboef4h4YbXXhNhPwMbkHTpkf3zLhx7HvFw1NDy")
        //        XCTAssertEqual(privateKey.xpriv, "xprv9s21ZrQH143K3h3fDYiay8mocZ3afhfULfb5GX8kCBdno77K4HiA15Tg23wpbeF1pLfs1c5SPmYHrEpTuuRhxMwvKDwqdKiGJS9XFKzUsAF")
        //
        //        let keychain = HDKeychain(privateKey: privateKey)
        //
        //        let wallet = HDWallet(keychain: keychain)
        //
        //        let pathString = "m/44'/0'/0'"
        //
        //        let childKeyPath = HDKeyPath(pathString)!
        //
        //        let childKey: HDPrivateKey = try wallet.privateKey(at: childKeyPath)
        //
        //        XCTAssertEqual(childKey.publicKey, HDPublicKey("0331e9b0c6b7f3798bb1b5a6b90c5e2e27c2906cbfd063a3c97b6031ee062ef745")!)
        //        XCTAssertEqual(childKey.xpub, "xpub6D3Cj1d8RgE6BRaEyYiRsJ8T17QA6Vq8F4P8f13BvDQTfgiBVT5iSdeSJ2QLSRijq2PMBXRSgduEUq11mYggQz6vUEe7Ga9e86urZjkrmeR")
        //        XCTAssertEqual(childKey.xpriv, "xprv9z3rKW6EbJfnxwVmsXBRWABiT5Zfh37GsqTXrcdaMssUntP2wumTtqKxSkZsytaxQZknwAhb3U8UR5cc3cxoMxdo4871tPPCTmeqckJyrWL")
    }
}
