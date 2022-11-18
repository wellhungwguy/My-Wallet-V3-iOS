// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Blockchain
import FeatureStakingDomain
import ToolKit

public final class EarnRepository: EarnRepositoryAPI {

    public var product: String { client.product }

    private let client: EarnClient

    private lazy var cache = (
        balances: cache(client.balances(in:)),
        eligibility: cache(client.eligibility),
        userRates: cache(client.userRates),
        limits: cache(client.limits),
        address: cache(client.address(currency:)),
        activity: cache(client.activity(currency:))
    )

    public init(client: EarnClient) {
        self.client = client
    }

    public func balances(
        in currency: FiatCurrency
    ) -> AnyPublisher<EarnAccounts, Nabu.Error> {
        cache.balances.get(key: currency)
    }

    public func invalidateBalances() {
        cache.balances.invalidateCache()
    }

    public func eligibility() -> AnyPublisher<EarnEligibility, Nabu.Error> {
        cache.eligibility.get(key: #line)
    }

    public func userRates() -> AnyPublisher<EarnUserRates, Nabu.Error> {
        cache.userRates.get(key: #line)
    }

    public func limits() -> AnyPublisher<EarnLimits, Nabu.Error> {
        cache.limits.get(key: #line)
    }

    public func address(currency: CryptoCurrency) -> AnyPublisher<EarnAddress, Nabu.Error> {
        cache.address.get(key: currency)
    }

    public func activity(currency: CryptoCurrency) -> AnyPublisher<[EarnActivity], Nabu.Error> {
        cache.activity.get(key: currency)
    }

    public func deposit(amount: MoneyValue) -> AnyPublisher<Void, Nabu.Error> {
        client.deposit(amount: amount)
    }

    public func withdraw(amount: MoneyValue) -> AnyPublisher<Void, Nabu.Error> {
        client.withdraw(amount: amount)
    }
}

extension EarnRepository {

    fileprivate func cache<Value>(_ publisher: @escaping () -> AnyPublisher<Value, Nabu.Error>) -> CachedValueNew<Int, Value, Nabu.Error> {
        cache { _  in publisher() }
    }

    fileprivate func cache<Key, Value>(_ publisher: @escaping (Key) -> AnyPublisher<Value, Nabu.Error>) -> CachedValueNew<Key, Value, Nabu.Error> {
        CachedValueNew(
            cache: InMemoryCache(
                configuration: .onLoginLogoutTransactionAndDashboardRefresh(),
                refreshControl: PeriodicCacheRefreshControl(refreshInterval: 180)
            )
            .eraseToAnyCache(),
            fetch: publisher
        )
    }
}
