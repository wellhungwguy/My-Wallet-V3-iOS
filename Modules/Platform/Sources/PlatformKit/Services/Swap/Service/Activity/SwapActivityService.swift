// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import Errors
import MoneyKit
import ToolKit

public protocol SwapActivityServiceAPI: AnyObject {
    func fetchActivity(
        cryptoCurrency: CryptoCurrency,
        directions: Set<OrderDirection>
    ) -> AnyPublisher<[SwapActivityItemEvent], NabuNetworkError>
}

final class SwapActivityService: SwapActivityServiceAPI {

    // MARK: Types

    private struct Key: Hashable {}

    // MARK: Private Properties

    private let client: SwapClientAPI
    private let fiatCurrencyProvider: FiatCurrencySettingsServiceAPI
    private let cachedValue: CachedValueNew<
        Key,
        [SwapActivityItemEvent],
        NabuNetworkError
    >

    // MARK: Init

    init(
        client: SwapClientAPI,
        fiatCurrencyProvider: CompleteSettingsServiceAPI
    ) {
        self.fiatCurrencyProvider = fiatCurrencyProvider
        self.client = client

        let cache: AnyCache<Key, [SwapActivityItemEvent]> = InMemoryCache(
            configuration: .onLoginLogout(),
            refreshControl: PeriodicCacheRefreshControl(refreshInterval: 30)
        ).eraseToAnyCache()

        self.cachedValue = CachedValueNew(
            cache: cache,
            fetch: { [client] _ in
                fiatCurrencyProvider.displayCurrency
                    .setFailureType(to: NabuNetworkError.self)
                    .flatMap { fiatCurrency in
                        client.fetchActivity(
                            from: Date(),
                            fiatCurrency: fiatCurrency.code,
                            cryptoCurrency: nil,
                            limit: 50
                        )
                    }
                    .eraseToAnyPublisher()
            }
        )
    }

    func fetchActivity(
        cryptoCurrency: CryptoCurrency,
        directions: Set<OrderDirection>
    ) -> AnyPublisher<[SwapActivityItemEvent], NabuNetworkError> {
        cachedValue.get(key: Key())
            .map { events in
                events
                    .filter { event in
                        directions.contains(event.kind.direction)
                            && event.pair.inputCurrencyType == cryptoCurrency
                    }
            }
            .eraseToAnyPublisher()
    }
}
