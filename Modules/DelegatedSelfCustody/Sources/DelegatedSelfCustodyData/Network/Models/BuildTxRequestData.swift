// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DelegatedSelfCustodyDomain

struct BuildTxRequestData: Encodable {
    let account: Int
    let amount: String
    let currency: String
    let destination: String
    let fee: String
    let feeCurrency: String
    let maxVerificationVersion: Int?
    let memo: String
    let type: String
}

extension BuildTxRequestData {
    public init(input: DelegatedCustodyTransactionInput) {
        account = input.account
        amount = input.amount.stringValue
        currency = input.currency
        destination = input.destination
        fee = input.fee.stringValue
        feeCurrency = input.feeCurrency
        maxVerificationVersion = input.maxVerificationVersion
        memo = input.memo
        type = input.type
    }
}

extension DelegatedCustodyFee {
    var stringValue: String {
        switch self {
        case .low:
            return "LOW"
        case .normal:
            return "NORMAL"
        case .high:
            return "HIGH"
        case .custom(let value):
            return value
        }
    }
}

extension DelegatedCustodyAmount {
    var stringValue: String {
        switch self {
        case .max:
            return "MAX"
        case .custom(let value):
            return value
        }
    }
}
