// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import DIKit
import Errors
import MoneyKit
import PlatformKit
import ToolKit

final class InterestAccountEligibilityRepository: InterestAccountEligibilityRepositoryAPI {

    private let enabledCurrenciesService: EnabledCurrenciesServiceAPI
    private let client: InterestAccountEligibilityClientAPI
    private let cachedValue: CachedValueNew<
        String,
        [InterestAccountEligibility],
        InterestAccountEligibilityError
    >

    init(
        client: InterestAccountEligibilityClientAPI = resolve(),
        enabledCurrenciesService: EnabledCurrenciesServiceAPI = resolve()
    ) {
        self.enabledCurrenciesService = enabledCurrenciesService
        self.client = client

        let cache: AnyCache<String, [InterestAccountEligibility]> = InMemoryCache(
            configuration: .onUserStateChanged(),
            refreshControl: PeriodicCacheRefreshControl(refreshInterval: 180)
        ).eraseToAnyCache()

        self.cachedValue = CachedValueNew(
            cache: cache,
            fetch: { [client] _ in

                func enabledCurrencies() -> AnyPublisher<[CurrencyType], NabuNetworkError> {
                    client
                        .fetchInterestEnabledCurrenciesResponse()
                        .map(\.instruments)
                        .map { currencyCodes in
                            currencyCodes.compactMap { try? CurrencyType(code: $0) }
                        }
                        .eraseToAnyPublisher()
                }

                return client.fetchInterestAccountEligibilityResponse()
                    .zip(enabledCurrencies())
                    .map { eligbilityResponse, enabledCurrencies -> [InterestAccountEligibility] in
                        enabledCurrencies
                            .map { asset -> InterestAccountEligibility in
                                guard let eligibility = eligbilityResponse[asset] else {
                                    return InterestAccountEligibility.notEligible(currencyType: asset)
                                }
                                return InterestAccountEligibility(currencyType: asset, interestEligibility: eligibility)
                            }
                    }
                    .mapError(InterestAccountEligibilityError.networkError)
                    .eraseToAnyPublisher()
            }
        )
    }

    func fetchAllInterestAccountEligibility()
        -> AnyPublisher<[InterestAccountEligibility], InterestAccountEligibilityError>
    {
        cachedValue.get(key: #file).eraseToAnyPublisher()
    }

    func fetchInterestAccountEligibilityForCurrencyCode(
        _ currency: CurrencyType
    ) -> AnyPublisher<InterestAccountEligibility, InterestAccountEligibilityError> {
        cachedValue.get(key: #file)
            .map { eligibilities in
                eligibilities.first { eligibility in
                    eligibility.currencyType.code == currency.code
                }
            }
            .replaceNil(with: .notEligible(currencyType: currency))
            .eraseToAnyPublisher()
    }
}
