// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BigInt
import PlatformKit
import WalletCore

public struct EthereumTransactionEncoded {

    public let transactionHash: String
    let encodedTransaction: Data

    var rawTransaction: String {
        encodedTransaction.hexValue.withHex.lowercased()
    }

    init(transaction: WalletCore.EthereumSigningOutput) {
        self.init(encodedTransaction: transaction.encoded)
    }

    init(encodedTransaction: Data) {
        self.transactionHash = Hash.keccak256(data: encodedTransaction).hexString.withHex
        self.encodedTransaction = encodedTransaction
    }
}
