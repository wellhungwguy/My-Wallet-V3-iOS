// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import DIKit
import Errors
import EthereumKit
import Foundation
import MoneyKit
import ToolKit

final class HistoricalTransactionsRepository: HistoricalTransactionsRepositoryAPI {

    private struct Key: Hashable {
        let identifier: String
    }

    private let transactionClient: TransactionClientAPI
    private let latestBlockRepository: LatestBlockRepositoryAPI

    private let transactionsCachedValue: CachedValueNew<
        Key,
        [EthereumHistoricalTransaction],
        NetworkError
    >
    private let transactionCachedValue: CachedValueNew<
        Key,
        EthereumHistoricalTransaction,
        NetworkError
    >

    init(
        transactionClient: TransactionClientAPI,
        latestBlockRepository: LatestBlockRepositoryAPI
    ) {
        self.transactionClient = transactionClient
        self.latestBlockRepository = latestBlockRepository

        let transactionsCache: AnyCache<Key, [EthereumHistoricalTransaction]> = InMemoryCache(
            configuration: .default(),
            refreshControl: PeriodicCacheRefreshControl(refreshInterval: 60)
        ).eraseToAnyCache()

        transactionsCachedValue = CachedValueNew(
            cache: transactionsCache,
            fetch: { [transactionClient] key in
                transactionClient
                    .transactions(
                        for: key.identifier
                    )
                    .zip(
                        latestBlockRepository
                            .latestBlock(network: .ethereum)
                    )
                    .map { transactions, latestBlock in
                        transactions.map { transaction in
                            EthereumHistoricalTransaction(
                                response: transaction,
                                accountAddress: key.identifier,
                                latestBlock: latestBlock
                            )
                        }
                        // Sort most recent first.
                        .sorted(by: >)
                    }
                    .eraseToAnyPublisher()
            }
        )
        let transactionCache: AnyCache<Key, EthereumHistoricalTransaction> = InMemoryCache(
            configuration: .default(),
            refreshControl: PeriodicCacheRefreshControl(refreshInterval: 60)
        ).eraseToAnyCache()

        transactionCachedValue = CachedValueNew(
            cache: transactionCache,
            fetch: { [transactionClient] key in
                transactionClient
                    .transaction(
                        with: key.identifier
                    )
                    .zip(
                        latestBlockRepository
                            .latestBlock(network: .ethereum)
                    )
                    .map { response, latestBlock in
                        EthereumHistoricalTransaction(
                            response: response,
                            accountAddress: key.identifier,
                            latestBlock: latestBlock
                        )
                    }
                    .eraseToAnyPublisher()
            }
        )
    }

    func transaction(
        identifier: String
    ) -> AnyPublisher<EthereumHistoricalTransaction, NetworkError> {
        transactionCachedValue.get(
            key: Key(identifier: identifier)
        )
    }

    func transactions(
        address: String
    ) -> AnyPublisher<[EthereumHistoricalTransaction], NetworkError> {
        transactionsCachedValue.get(
            key: Key(identifier: address)
        )
    }
}

extension EthereumHistoricalTransaction {

    public init(
        response: EthereumHistoricalTransactionResponse,
        note: String? = nil,
        accountAddress: String,
        latestBlock: BigInt
    ) {
        let direction = EthereumHistoricalTransaction.direction(
            to: response.to,
            from: response.from,
            accountAddress: accountAddress
        )
        let amount = CryptoValue.create(
            minor: response.value,
            currency: .ethereum
        ) ?? .zero(currency: .ethereum)
        let fee = EthereumHistoricalTransaction.fee(
            gasPrice: response.gasPrice,
            gasUsed: response.gasUsed
        )
        let confirmations = EthereumHistoricalTransaction.confirmations(
            latestBlock: latestBlock,
            blockNumber: response.blockNumber
        )

        self.init(
            identifier: response.hash,
            fromAddress: EthereumAddress(address: response.from, network: .ethereum)!,
            toAddress: EthereumAddress(address: response.to, network: .ethereum)!,
            direction: direction,
            amount: amount,
            transactionHash: response.hash,
            createdAt: response.createdAt,
            fee: fee,
            note: note,
            confirmations: confirmations,
            data: response.data,
            state: response.state
        )
    }

    private static func created(timestamp: Int) -> Date {
        Date(timeIntervalSince1970: TimeInterval(timestamp))
    }

    private static func direction(to: String, from: String, accountAddress: String) -> EthereumDirection {
        let incoming = to.lowercased() == accountAddress.lowercased()
        let outgoing = from.lowercased() == accountAddress.lowercased()
        if incoming, outgoing {
            return .transfer
        }
        if incoming {
            return .receive
        }
        return .send
    }

    private static func fee(gasPrice: String, gasUsed: String?) -> CryptoValue {
        let ethereum = CryptoCurrency.ethereum
        guard let gasUsed else {
            return .zero(currency: ethereum)
        }
        guard let gasPrice = BigInt(gasPrice),
              let gasUsed = BigInt(gasUsed)
        else {
            return .zero(currency: ethereum)
        }
        return CryptoValue
            .create(
                minor: gasPrice * gasUsed,
                currency: ethereum
            )
    }

    private static func confirmations(latestBlock: BigInt, blockNumber: String?) -> Int {
        blockNumber
            .flatMap { BigInt($0) }
            .flatMap { blockNumber in
                let difference = (latestBlock - blockNumber) + 1
                let confirmations = max(difference, 0)
                return Int(confirmations)
            }
            ?? 0
    }
}
