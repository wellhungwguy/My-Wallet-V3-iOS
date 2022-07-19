// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation
import MoneyKit

public struct DelegatedCustodyActivity: Equatable {

    public enum Status {
        case pending
        case failed
        case completed
        case confirming
    }

    public let coin: CryptoCurrency
    public let fee: CryptoValue
    public let from: String
    public let status: Status
    public let timestamp: Date
    public let to: String
    public let transactionID: String
    public let value: CryptoValue

    public init(
        coin: CryptoCurrency,
        fee: CryptoValue,
        from: String,
        status: DelegatedCustodyActivity.Status,
        timestamp: Date,
        to: String,
        transactionID: String,
        value: CryptoValue
    ) {
        self.coin = coin
        self.fee = fee
        self.from = from
        self.status = status
        self.timestamp = timestamp
        self.to = to
        self.transactionID = transactionID
        self.value = value
    }
}
