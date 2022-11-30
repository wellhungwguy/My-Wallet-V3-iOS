// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainNamespace
import Combine
import DIKit
import Errors
import PlatformKit
import ToolKit

public typealias FetchUnspentOutputsFor = ([XPub]) -> AnyPublisher<UnspentOutputs, NetworkError>

public protocol UnspentOutputRepositoryAPI {

    /// Emits unspent outputs of the provided addresses (extended public key)
    func unspentOutputs(
        for addresses: [XPub],
        forceFetch: Bool
    ) -> AnyPublisher<UnspentOutputs, NetworkError>

    func invalidateCache()
}

extension UnspentOutputRepositoryAPI {

    public func unspentOutputs(
        for addresses: [XPub]
    ) -> AnyPublisher<UnspentOutputs, NetworkError> {
        unspentOutputs(for: addresses, forceFetch: false)
    }
}

final class UnspentOutputRepository: UnspentOutputRepositoryAPI {

    // MARK: - Private properties

    private let client: APIClientAPI
    private let cachedValue: CachedValueNew<
        Set<XPub>, UnspentOutputs, NetworkError
    >

    private var cancellables: Set<AnyCancellable> = []

    // MARK: - Init

    init(
        client: BitcoinChainKit.APIClientAPI,
        coin: BitcoinChainCoin,
        app: AppProtocol
    ) {
        self.client = client
        let remoteConfigControl = RemotePeriodicCacheRefreshControl(
            defaultConfig: .init(interval: 30, disable: false),
            fetch: {
                app.publisher(
                    for: blockchain.app.configuration.unspent.outputs.cache.config,
                    as: RemoteCacheConfig?.self
                )
                .compactMap(\.value)
                .eraseError()
                .eraseToAnyPublisher()
            }
        )
        let cache: AnyCache<Set<XPub>, UnspentOutputs> = InMemoryCache(
            configuration: .onLoginLogoutTransaction(),
            refreshControl: remoteConfigControl
        ).eraseToAnyCache()
        cachedValue = CachedValueNew(
            cache: cache,
            fetch: { [client] xPubs in
                client
                    .unspentOutputs(for: Array(xPubs))
                    .map { response in
                        UnspentOutputs(networkResponse: response, coin: coin)
                    }
                    .eraseToAnyPublisher()
            }
        )
    }

    // MARK: - Methods

    func unspentOutputs(
        for addresses: [XPub],
        forceFetch: Bool
    ) -> AnyPublisher<UnspentOutputs, NetworkError> {
        cachedValue.get(key: Set(addresses), forceFetch: forceFetch)
    }

    func invalidateCache() {
        cachedValue.invalidateCache()
    }
}
