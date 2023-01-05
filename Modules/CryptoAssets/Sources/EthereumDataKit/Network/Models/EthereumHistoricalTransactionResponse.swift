// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BigInt
import EthereumKit
import Foundation

struct EthereumAccountTransactionsResponse: Decodable {
    let transactions: [EthereumHistoricalTransactionResponse]
}

public struct EthereumHistoricalTransactionResponse: Decodable {

    public var createdAt: Date {
        timestamp
            .flatMap(TimeInterval.init)
            .flatMap(Date.init(timeIntervalSince1970:)) ?? .distantPast
    }

    public let blockNumber: String?
    public let from: String
    public let gasPrice: String
    public let gasUsed: String?
    public let hash: String
    public let state: EthereumTransactionState
    public let to: String
    public let value: String
    public let data: String?
    private let timestamp: String?
}
