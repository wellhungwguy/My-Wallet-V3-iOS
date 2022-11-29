// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import FeatureStakingDomain
import MoneyKit
import ToolKit

final class StakingBalanceRepository: StakingBalanceRepositoryAPI {

    private let balanceProvider: GetStakingAllBalances

    private let cachedValue: CachedValueNew<
        FiatCurrency,
        StakingAccountBalances,
        StakingRepositoryError
    >

    init(balanceProvider: @escaping GetStakingAllBalances) {
        self.balanceProvider = balanceProvider

        let cache: AnyCache<FiatCurrency, StakingAccountBalances> = InMemoryCache(
            configuration: .onLoginLogoutTransaction(),
            refreshControl: PeriodicCacheRefreshControl(refreshInterval: 60)
        )
        .eraseToAnyCache()
        cachedValue = CachedValueNew(
            cache: cache,
            fetch: { [balanceProvider] key in
                balanceProvider(key)
                    .replaceNil(with: .empty)
                    .mapError(StakingRepositoryError.networkError)
                    .map(StakingAccountBalances.init)
                    .eraseToAnyPublisher()
            }
        )
    }

    func getAllBalances(
        fiatCurrency: FiatCurrency
    ) -> AnyPublisher<StakingAccountBalances, StakingRepositoryError> {
        cachedValue.get(key: fiatCurrency)
    }

    func invalidateAllBalances() {
        cachedValue.invalidateCache()
    }
}
