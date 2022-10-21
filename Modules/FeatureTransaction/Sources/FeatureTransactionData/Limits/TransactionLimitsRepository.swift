// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import Errors
import FeatureTransactionDomain
import MoneyKit
import PlatformKit
import ToolKit

final class TransactionLimitsRepository: TransactionLimitsRepositoryAPI {

    struct TradeLimitsKey: Hashable {
        let currency: CurrencyType
        let product: TransactionLimitsProduct
    }

    struct CrossBorderLimitsKey: Hashable {
        let source: LimitsAccount
        let destination: LimitsAccount
        let currency: CurrencyType
    }

    // MARK: - Properties

    private let client: TransactionLimitsClientAPI
    private let tradeLimitsCache: CachedValueNew<
        TradeLimitsKey,
        TradeLimits,
        Nabu.Error
    >
    private let crossBorderLimitsCache: CachedValueNew<
        CrossBorderLimitsKey,
        CrossBorderLimits,
        Nabu.Error
    >

    // MARK: - Setup

    init(client: TransactionLimitsClientAPI) {
        self.client = client

        do {
            let cache: AnyCache<TradeLimitsKey, TradeLimits> = InMemoryCache(
                configuration: .onLoginLogoutKYCChanged(),
                refreshControl: PerpetualCacheRefreshControl()
            ).eraseToAnyCache()

            tradeLimitsCache = CachedValueNew(
                cache: cache,
                fetch: { key in
                    client.fetchTradeLimits(
                        currency: key.currency,
                        product: key.product
                    )
                    .map(TradeLimits.init)
                    .eraseToAnyPublisher()
                }
            )
        }

        do {
            let cache: AnyCache<CrossBorderLimitsKey, CrossBorderLimits> = InMemoryCache(
                configuration: .onLoginLogoutKYCChanged(),
                refreshControl: PerpetualCacheRefreshControl()
            ).eraseToAnyCache()

            crossBorderLimitsCache = CachedValueNew(
                cache: cache,
                fetch: { key in
                    client
                        .fetchCrossBorderLimits(
                            source: key.source,
                            destination: key.destination,
                            limitsCurrency: key.currency
                        )
                        .map(CrossBorderLimits.init)
                    .eraseToAnyPublisher()
                }
            )
        }
    }

    // MARK: - TransactionLimitServiceAPI

    func fetchTradeLimits(
        sourceCurrency: CurrencyType,
        product: TransactionLimitsProduct
    ) -> AnyPublisher<TradeLimits, NabuNetworkError> {
        tradeLimitsCache.get(
            key: .init(
                currency: sourceCurrency,
                product: product
            )
        )
        .receive(on: DispatchQueue.main)
        .eraseToAnyPublisher()
    }

    func fetchCrossBorderLimits(
        source: LimitsAccount,
        destination: LimitsAccount,
        limitsCurrency: FiatCurrency
    ) -> AnyPublisher<CrossBorderLimits, NabuNetworkError> {
        crossBorderLimitsCache.get(
            key: .init(
                source: source,
                destination: destination,
                currency: limitsCurrency.currencyType
            )
        )
        .receive(on: DispatchQueue.main)
        .eraseToAnyPublisher()
    }
}
