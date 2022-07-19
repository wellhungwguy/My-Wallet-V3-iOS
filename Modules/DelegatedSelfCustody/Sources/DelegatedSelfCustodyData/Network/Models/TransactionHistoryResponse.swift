// Copyright © Blockchain Luxembourg S.A. All rights reserved.

struct TransactionHistoryResponse: Decodable {
    enum Status: String, Decodable {
        case pending = "PENDING"
        case failed = "FAILED"
        case completed = "COMPLETED"
        case confirming = "CONFIRMING"
    }

    struct Movement: Decodable {
        let type: Direction?
        let address: String
        let amount: String
        let identifier: String
    }

    enum Direction: String, Decodable {
        case sent = "SENT"
        case received = "RECEIVED"
    }

    struct Entry: Decodable {
        let txId: String
        let status: Status?
        let timestamp: Double?
        let fee: String
        let movements: [Movement]
    }

    let history: [Entry]
}
