// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import Errors
import FeatureCardIssuingDomain
import Foundation
import ToolKit

final class ProductsRepository: ProductsRepositoryAPI {

    private struct Key: Hashable {}

    private let cachedValue: CachedValueNew<
        Key,
        [Product],
        NabuNetworkError
    >
    private let client: ProductsClientAPI

    init(client: ProductsClientAPI) {
        self.client = client

        let cache: AnyCache<Key, [Product]> = InMemoryCache(
            configuration: .onLoginLogout(),
            refreshControl: PeriodicCacheRefreshControl(refreshInterval: 60)
        ).eraseToAnyCache()

        self.cachedValue = CachedValueNew(
            cache: cache,
            fetch: { _ in
                client.fetchProducts()
            }
        )
    }

    func fetchProducts() -> AnyPublisher<[Product], NabuNetworkError> {
        cachedValue.get(key: Key())
    }
}
