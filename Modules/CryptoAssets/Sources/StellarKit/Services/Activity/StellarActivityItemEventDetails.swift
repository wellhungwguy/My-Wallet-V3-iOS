// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import MoneyKit
import PlatformKit

public struct StellarActivityItemEventDetails {

    public let cryptoAmount: CryptoValue
    public let createdAt: Date
    public let from: String
    public let to: String
    public let fee: CryptoValue?
    public let memo: String?
    public let transactionHash: String

    init(transaction: StellarHistoricalTransaction) {
        self.transactionHash = transaction.transactionHash
        self.cryptoAmount = transaction.amount
        self.createdAt = transaction.createdAt
        self.from = transaction.fromAddress.publicKey
        self.to = transaction.toAddress.publicKey
        self.fee = transaction.fee
        self.memo = transaction.memo
    }
}
