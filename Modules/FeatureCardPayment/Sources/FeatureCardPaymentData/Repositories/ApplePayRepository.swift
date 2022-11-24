// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import DIKit
import Errors
import FeatureCardPaymentDomain
import Foundation
import ToolKit

final class ApplePayRepository: ApplePayRepositoryAPI {

    private struct Key: Hashable {}

    private let client: ApplePayClientAPI

    private let cachedEligibleValue: CachedValueNew<
        Key,
        Bool,
        Never
    >

    private let cachedInfoValue: CachedValueNew<
        String,
        ApplePayInfo,
        NabuNetworkError
    >

    init(
        client: ApplePayClientAPI,
        eligibleService: ApplePayEligibleServiceAPI
    ) {
        self.client = client
        let cache: AnyCache<Key, Bool> = InMemoryCache(
            configuration: .onLoginLogout(),
            refreshControl: PerpetualCacheRefreshControl()
        ).eraseToAnyCache()

        let infoCache: AnyCache<String, ApplePayInfo> = InMemoryCache(
            configuration: .onLoginLogout(),
            refreshControl: PeriodicCacheRefreshControl(refreshInterval: 30)
        ).eraseToAnyCache()

        self.cachedEligibleValue = CachedValueNew(
            cache: cache,
            fetch: { _ in
                eligibleService.isBackendEnabled()
            }
        )

        self.cachedInfoValue = CachedValueNew(
            cache: infoCache,
            fetch: { currency in
                client.applePayInfo(for: currency)
            }
        )
    }

    func applePayInfo(for currency: String) -> AnyPublisher<ApplePayInfo, NabuNetworkError> {
        cachedInfoValue.get(key: currency, forceFetch: true)
    }
}
