// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BigInt
import Combine
import DIKit
import MoneyKit
import PlatformKit
import ToolKit

public enum EthereumBalanceRepositoryError: Error {
    case failed(Error)
}

public protocol EthereumBalanceRepositoryAPI {
    func invalidateCache()
    func balance(
        network: EVMNetwork,
        for address: String
    ) -> AnyPublisher<CryptoValue, EthereumBalanceRepositoryError>
}

final class EthereumBalanceRepository: EthereumBalanceRepositoryAPI {

    private struct Key: Hashable {
        let network: EVMNetwork
        let address: String
    }

    private let client: GetBalanceClientAPI
    private let cachedValue: CachedValueNew<
        Key,
        CryptoValue,
        EthereumBalanceRepositoryError
    >

    init(
        client: GetBalanceClientAPI = resolve()
    ) {
        self.client = client

        let cache: AnyCache<Key, CryptoValue> = InMemoryCache(
            configuration: .onLoginLogoutTransaction(),
            refreshControl: PeriodicCacheRefreshControl(refreshInterval: 30)
        ).eraseToAnyCache()

        self.cachedValue = CachedValueNew(
            cache: cache,
            fetch: { [client] key in
                client
                    .balance(
                        network: key.network,
                        address: key.address
                    )
                    .map { response -> CryptoValue in
                        CryptoValue.create(
                            minor: response.result,
                            currency: key.network.nativeAsset
                        )
                    }
                    .mapError(EthereumBalanceRepositoryError.failed)
                    .eraseToAnyPublisher()
            }
        )
    }

    func invalidateCache() {
        cachedValue.invalidateCache()
    }

    func balance(
        network: EVMNetwork,
        for address: String
    ) -> AnyPublisher<CryptoValue, EthereumBalanceRepositoryError> {
        cachedValue.get(
            key: Key(network: network, address: address)
        )
    }
}
