// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BigInt
import Combine
import DIKit
import MoneyKit
import PlatformKit
import ToolKit

public enum EthereumNonceRepositoryError: Error {
    case failed(Error)
}

public protocol EthereumNonceRepositoryAPI {
    func invalidateCache()
    func nonce(
        network: EVMNetwork,
        for address: String
    ) -> AnyPublisher<BigUInt, EthereumNonceRepositoryError>
}

final class EthereumNonceRepository: EthereumNonceRepositoryAPI {

    private struct Key: Hashable {
        let network: EVMNetwork
        let address: String
    }

    private let client: GetTransactionCountClientAPI
    private let cachedValue: CachedValueNew<
        Key,
        BigUInt,
        EthereumNonceRepositoryError
    >

    init(
        client: GetTransactionCountClientAPI = resolve()
    ) {
        self.client = client

        let cache: AnyCache<Key, BigUInt> = InMemoryCache(
            configuration: .onLoginLogoutTransaction(),
            refreshControl: PeriodicCacheRefreshControl(refreshInterval: 30)
        ).eraseToAnyCache()

        self.cachedValue = CachedValueNew(
            cache: cache,
            fetch: { [client] key in
                client
                    .transactionCount(network: key.network, address: key.address)
                    .map(\.result.magnitude)
                    .mapError(EthereumNonceRepositoryError.failed)
                    .eraseToAnyPublisher()
            }
        )
    }

    func invalidateCache() {
        cachedValue.invalidateCache()
    }

    func nonce(
        network: EVMNetwork,
        for address: String
    ) -> AnyPublisher<BigUInt, EthereumNonceRepositoryError> {
        cachedValue.get(key: Key(network: network, address: address))
    }
}
