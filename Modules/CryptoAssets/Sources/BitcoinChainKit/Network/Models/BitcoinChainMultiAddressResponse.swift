// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

public protocol BitcoinChainHistoricalTransactionResponse: Decodable, Equatable {

    func applying(latestBlockHeight: Int) -> Self
}

public struct BitcoinChainMultiAddressResponse<T: BitcoinChainHistoricalTransactionResponse>: Decodable, Equatable {

    public let addresses: [BitcoinChainAddressResponse]
    public let transactions: [T]
    public let latestBlockHeight: Int

    enum RootCodingKeys: String, CodingKey {
        case addresses
        case txs
        case info
    }

    enum InfoCodingKeys: String, CodingKey {
        case latestBlock = "latest_block"
    }

    enum LatestBlockCodingKeys: String, CodingKey {
        case height
    }

    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: RootCodingKeys.self)
        let info = try values.nestedContainer(keyedBy: InfoCodingKeys.self, forKey: .info)
        let latestBlock = try info.nestedContainer(keyedBy: LatestBlockCodingKeys.self, forKey: .latestBlock)
        self.addresses = try values.decode([BitcoinChainAddressResponse].self, forKey: .addresses)

        let _latestBlockHeight = try latestBlock.decode(Int.self, forKey: .height)
        self.latestBlockHeight = _latestBlockHeight

        let txs = try values.decode([T].self, forKey: .txs)

        self.transactions = txs.map { transaction in
            transaction.applying(latestBlockHeight: _latestBlockHeight)
        }
    }

    init(
        addresses: [BitcoinChainAddressResponse],
        transactions: [T],
        latestBlockHeight: Int
    ) {
        self.addresses = addresses
        self.transactions = transactions
        self.latestBlockHeight = latestBlockHeight
    }
}
