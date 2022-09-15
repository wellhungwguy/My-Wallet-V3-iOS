// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BigInt
import BitcoinChainKit
import CryptoSwift
import Foundation
import MoneyKit

extension UnspentOutput {

    static func create(
        with value: CryptoValue,
        hash: String,
        script: String,
        confirmations: UInt,
        transactionIndex: Int,
        outputIndex: Int,
        m: String,
        path: String
    ) -> UnspentOutput {
        UnspentOutput(
            confirmations: confirmations,
            hash: hash,
            hashBigEndian: Data(hex: hash).reversed().toHexString(),
            outputIndex: outputIndex,
            script: script,
            transactionIndex: transactionIndex,
            value: value,
            xpub: XPub(m: m, path: path)
        )
    }

    static func createP2PKH(
        with value: CryptoValue = .zero(currency: .bitcoin),
        hash: String = "00",
        confirmations: UInt = 0,
        transactionIndex: Int = 0,
        outputIndex: Int = 0,
        m: String = "",
        path: String = "M/0/0"
    ) -> UnspentOutput {
        UnspentOutput.create(
            with: value,
            hash: hash,
            script: "76a914641ad5051edd97029a003fe9efb29359fcee409d88ac",
            confirmations: confirmations,
            transactionIndex: transactionIndex,
            outputIndex: outputIndex,
            m: m,
            path: path
        )
    }

    static func createP2WPKH(
        with value: CryptoValue = .zero(currency: .bitcoin),
        hash: String = "00",
        confirmations: UInt = 0,
        transactionIndex: Int = 0,
        outputIndex: Int = 0,
        m: String = "",
        path: String = "M/0/0"
    ) -> UnspentOutput {
        UnspentOutput.create(
            with: value,
            hash: hash,
            script: "0014326e987644fa2d8ddf813ad40aa09b9b1229b71f",
            confirmations: confirmations,
            transactionIndex: transactionIndex,
            outputIndex: outputIndex,
            m: m,
            path: path
        )
    }
}
