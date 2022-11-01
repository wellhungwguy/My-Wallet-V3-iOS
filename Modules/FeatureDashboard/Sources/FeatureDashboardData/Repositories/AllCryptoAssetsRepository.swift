// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainNamespace
import Combine
import CombineExtensions
import FeatureDashboardDomain
import Foundation
import MoneyKit
import PlatformKit
import ToolKit

public final class AllCryptoAssetsRepository: AllCryptoAssetsRepositoryAPI {
    private struct Key: Hashable {}

    public var assetsInfo: AnyPublisher<[CryptoAssetInfo], Error> {
        cachedValue.get(key: Key())
    }

    private let cachedValue: CachedValueNew<
        Key,
        [CryptoAssetInfo],
        Error
    >
    private let allCryptoAssetService: AllCryptoAssetsServiceAPI

    public init(
        allCryptoAssetService: AllCryptoAssetsServiceAPI
    ) {
        self.allCryptoAssetService = allCryptoAssetService

        let cache: AnyCache<Key, [CryptoAssetInfo]> = InMemoryCache(
            configuration: .onLoginLogoutTransaction(),
            refreshControl: PeriodicCacheRefreshControl(refreshInterval: 60)
        )
        .eraseToAnyCache()

        cachedValue = CachedValueNew(
            cache: cache,
            fetch: { [allCryptoAssetService] _ -> AnyPublisher<[CryptoAssetInfo], Error> in
                allCryptoAssetService
                    .getAllCryptoAssetsInfoPublisher()
                    .eraseError()
            }
        )
    }
}
