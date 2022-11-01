// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BigInt
import Combine
import Errors
import EthereumKit
import MoneyKit
import ToolKit

final class LatestBlockRepository: LatestBlockRepositoryAPI {

    private let client: LatestBlockClientAPI
    private let cachedValue: CachedValueNew<
        EVMNetworkConfig,
        BigInt,
        NetworkError
    >

    init(client: LatestBlockClientAPI) {
        self.client = client

        let cache: AnyCache<EVMNetworkConfig, BigInt> = InMemoryCache(
            configuration: .default(),
            refreshControl: PeriodicCacheRefreshControl(refreshInterval: 10)
        ).eraseToAnyCache()

        cachedValue = CachedValueNew(
            cache: cache,
            fetch: { [client] network in
                client
                    .latestBlock(network: network)
                    .map(\.result)
                    .eraseToAnyPublisher()
            }
        )
    }

    func latestBlock(
        network: EVMNetworkConfig
    ) -> AnyPublisher<BigInt, NetworkError> {
        cachedValue.get(key: network)
    }
}
