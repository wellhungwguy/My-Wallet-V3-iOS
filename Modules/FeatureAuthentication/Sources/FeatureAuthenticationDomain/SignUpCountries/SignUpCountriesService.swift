// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import ToolKit

public protocol SignUpCountriesServiceAPI {

    var countries: AnyPublisher<[Country], Error> { get }
}

public final class SignUpCountriesService: SignUpCountriesServiceAPI {

    private struct Key: Hashable {}

    // MARK: - Exposed

    /// Provides the countries fetched from remote
    public var countries: AnyPublisher<[Country], Error> {
        cachedValue.get(key: Key())
    }

    private let client: SignUpCountriesClientAPI
    private let cachedValue: CachedValueNew<
        Key,
        [Country],
        Error
    >

    init(client: SignUpCountriesClientAPI) {
        self.client = client

        let cache: AnyCache<Key, [Country]> = InMemoryCache(
            configuration: .onLoginLogout(),
            refreshControl: PeriodicCacheRefreshControl(refreshInterval: 60 * 60)
        ).eraseToAnyCache()
        cachedValue = CachedValueNew(
            cache: cache,
            fetch: { _ in
                client.countries
                    .map { countries in
                        countries
                            .sorted(by: { lhs, rhs in lhs.name.lowercased() < rhs.name.lowercased() })
                    }
                    .eraseError()
            }
        )
    }
}
