// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import Errors
import EthereumKit
import MoneyKit
import ToolKit

final class PendingTransactionRepository: PendingTransactionRepositoryAPI {

    private struct Key: Hashable {
        let network: EVMNetworkConfig
        let address: String
    }

    private let ethereumClient: TransactionClientAPI
    private let evmClient: EVMActivityClientAPI

    private let cachedValue: CachedValueNew<
        Key,
        Bool,
        NetworkError
    >

    init(
        ethereumClient: TransactionClientAPI,
        evmClient: EVMActivityClientAPI
    ) {
        self.evmClient = evmClient
        self.ethereumClient = ethereumClient

        let cache: AnyCache<Key, Bool> = InMemoryCache(
            configuration: .onLoginLogoutTransaction(),
            refreshControl: PeriodicCacheRefreshControl(refreshInterval: 5)
        ).eraseToAnyCache()

        cachedValue = CachedValueNew(
            cache: cache,
            fetch: { [evmClient, ethereumClient] key in
                switch key.network {
                case .ethereum:
                    return ethereumClient
                        .transactions(for: key.address)
                        .map { transactions in
                            transactions.contains(
                                where: { tx in tx.state == .pending }
                            )
                        }
                        .eraseToAnyPublisher()
                default:
                    return evmClient
                        .evmActivity(
                            address: key.address,
                            contractAddress: nil,
                            network: key.network
                        )
                        .map(\.history)
                        .map { history in
                            history.contains(where: { item in
                                item.status == .pending
                            })
                        }
                        .eraseToAnyPublisher()
                }
            }
        )
    }

    func isWaitingOnTransaction(
        network: EVMNetworkConfig,
        address: String
    ) -> AnyPublisher<Bool, NetworkError> {
        cachedValue.get(
            key: Key(network: network, address: address)
        )
    }
}
