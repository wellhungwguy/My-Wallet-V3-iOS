// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

public struct DelegatedCustodyTransactionInput {
    public let account: Int
    public let amount: DelegatedCustodyAmount
    public let currency: String
    public let destination: String
    public let fee: DelegatedCustodyFee
    public let feeCurrency: String
    public let maxVerificationVersion: Int?
    public let memo: String
    public let type: String

    public init(
        account: Int,
        amount: DelegatedCustodyAmount,
        currency: String,
        destination: String,
        fee: DelegatedCustodyFee,
        feeCurrency: String,
        maxVerificationVersion: Int?,
        memo: String,
        type: String
    ) {
        self.account = account
        self.amount = amount
        self.currency = currency
        self.destination = destination
        self.fee = fee
        self.feeCurrency = feeCurrency
        self.maxVerificationVersion = maxVerificationVersion
        self.memo = memo
        self.type = type
    }
}

public enum DelegatedCustodyFee {
    case low
    case normal
    case high
    case custom(String)
}

public enum DelegatedCustodyAmount {
    case max
    case custom(String)
}
