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

    public var assetsInfo: AnyPublisher<[AssetBalanceInfo], Error> {
        cachedValue.get(key: Key())
    }

    private let cachedValue: CachedValueNew<
        Key,
        [AssetBalanceInfo],
        Error
    >
    private let allCryptoAssetService: AllCryptoAssetsServiceAPI

    public init(
        allCryptoAssetService: AllCryptoAssetsServiceAPI
    ) {
        self.allCryptoAssetService = allCryptoAssetService

        let cache: AnyCache<Key, [AssetBalanceInfo]> = InMemoryCache(
            configuration: .onLoginLogout(),
            refreshControl: PeriodicCacheRefreshControl(refreshInterval: 320)
        )
        .eraseToAnyCache()

        cachedValue = CachedValueNew(
            cache: cache,
            fetch: { [allCryptoAssetService] _ -> AnyPublisher<[AssetBalanceInfo], Error> in
                allCryptoAssetService
                    .getAllCryptoAssetsInfoPublisher()
                    .eraseError()
            }
        )
    }
}
