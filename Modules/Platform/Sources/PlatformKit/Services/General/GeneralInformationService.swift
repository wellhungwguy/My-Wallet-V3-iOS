// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import ToolKit

public protocol GeneralInformationServiceAPI {

    var countries: AnyPublisher<[CountryData], Error> { get }
}

final class GeneralInformationService: GeneralInformationServiceAPI {

    // MARK: - Exposed

    /// Provides the countries fetched from remote
    var countries: AnyPublisher<[CountryData], Error> {
        cachedValue.get(key: "")
    }

    private let client: GeneralInformationClientAPI
    private let cachedValue: CachedValueNew<
        String,
        [CountryData],
        Error
    >

    init(client: GeneralInformationClientAPI) {
        self.client = client

        let cache: AnyCache<String, [CountryData]> = InMemoryCache(
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
