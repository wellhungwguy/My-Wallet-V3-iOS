// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import Errors
import FeatureProductsDomain
import ToolKit

public final class ProductsRepository: ProductsRepositoryAPI {

    private enum CacheKey: Hashable {
        case products
    }

    private let cachedProducts: CachedValueNew<CacheKey, [ProductValue], NabuNetworkError>

    public init(client: ProductsClientAPI) {
        let cache: AnyCache<CacheKey, [ProductValue]> = InMemoryCache(
            configuration: .onUserStateChanged(),
            refreshControl: PerpetualCacheRefreshControl()
        )
        .eraseToAnyCache()

        cachedProducts = CachedValueNew(
            cache: cache,
            fetch: { _ in
                client
                    .fetchProductsData()
                    .map(\ProductsAPIResponse.products)
                    .eraseToAnyPublisher()
            }
        )
    }

    public func fetchProducts() -> AnyPublisher<[ProductValue], NabuNetworkError> {
        cachedProducts.get(key: CacheKey.products)
    }

    public func streamProducts() -> AnyPublisher<Result<[ProductValue], NabuNetworkError>, Never> {
        cachedProducts.stream(key: CacheKey.products)
    }
}
