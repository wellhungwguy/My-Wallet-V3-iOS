// Copyright © Blockchain Luxembourg S.A. All rights reserved.

@testable import BitcoinChainKit
import Combine
import HDWalletKit
import MoneyKit
import XCTest

// swiftlint:disable line_length
class GetWalletKeyPairsTests: XCTestCase {

    func test_unspentOutput_derivation_path() throws {

        let unspentOutput = UnspentOutput(
            confirmations: 895,
            hash: "76bfad4cc0d1cbe454c1be0af7f8be2c8b1ca74f23d2a35306997e763b2f2273",
            hashBigEndian: "73222f3b767e990653a3d2234fa71c8b2cbef8f70abec154e4cbd1c04cadbf76",
            outputIndex: 0,
            script: "76a9141aedb27afebe4e4a2a943138ed436c35fe03f2ff88ac",
            transactionIndex: 4178099786226233,
            value: CryptoValue.create(minor: 5461495, currency: .bitcoinCash),
            xpub: UnspentOutput.XPub(
                m: "xpub6CLiRbHDgYwfFn19HnG3Jd6gr2eVWuiT8boBDnznqdVZtHNqG9nHFjQK4tgvRedu4isk8mYy2qNiUUarm5ifwBSHy7iFNsNwokpMZtdwPqG",
                path: "M/0/0"
            )
        )

        let expectedPathComponents: [HDWalletKit.DerivationComponent] = [
            .normal(0),
            .normal(0)
        ]

        let keyPath = try derivationPath(for: unspentOutput).get()

        XCTAssertEqual(keyPath.components, expectedPathComponents)
    }
}
