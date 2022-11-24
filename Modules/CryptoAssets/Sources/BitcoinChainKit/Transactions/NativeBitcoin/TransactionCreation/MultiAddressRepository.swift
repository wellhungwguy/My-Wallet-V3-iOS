// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import Errors
import Foundation
import MoneyKit
import ToolKit

public struct BitcoinChainMultiAddressData {
    public let addresses: [BitcoinChainAddressResponse]
    public let latestBlockHeight: Int

    public init(addresses: [BitcoinChainAddressResponse], latestBlockHeight: Int) {
        self.addresses = addresses
        self.latestBlockHeight = latestBlockHeight
    }
}

public typealias FetchMultiAddressFor = ([XPub]) -> AnyPublisher<BitcoinChainMultiAddressData, NetworkError>

public final class MultiAddressRepository<T: BitcoinChainHistoricalTransactionResponse> {

    private let client: APIClientAPI

    private let cachedValue: CachedValueNew<
        Set<XPub>,
        BitcoinChainMultiAddressResponse<T>,
        NetworkError
    >

    public init(client: APIClientAPI) {
        self.client = client

        let cache: AnyCache<Set<XPub>, BitcoinChainMultiAddressResponse<T>> = InMemoryCache(
            configuration: .onLoginLogoutTransaction(),
            refreshControl: PeriodicCacheRefreshControl(refreshInterval: 60)
        ).eraseToAnyCache()

        self.cachedValue = CachedValueNew(
            cache: cache,
            fetch: { key in
                client.multiAddress(for: key.map(\.self))
            }
        )
    }

    public func multiAddress(
        for wallets: [XPub]
    ) -> AnyPublisher<BitcoinChainMultiAddressResponse<T>, NetworkError> {
        multiAddress(for: wallets, forceFetch: false)
    }

    public func multiAddress(
        for wallets: [XPub],
        forceFetch: Bool
    ) -> AnyPublisher<BitcoinChainMultiAddressResponse<T>, NetworkError> {
        cachedValue.get(key: Set(wallets), forceFetch: forceFetch)
    }

    public func invalidateCache() {
        cachedValue.invalidateCache()
    }
}
