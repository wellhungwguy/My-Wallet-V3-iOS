// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import DIKit
import FeatureInterestDomain
import MoneyKit
import PlatformKit
import ToolKit

final class InterestAccountLimitsRepository: InterestAccountLimitsRepositoryAPI {

    // MARK: - Private Properties

    private let enabledCurrenciesService: EnabledCurrenciesServiceAPI
    private let client: InterestAccountLimitsClientAPI

    // MARK: - Init

    init(
        enabledCurrenciesService: EnabledCurrenciesServiceAPI = resolve(),
        client: InterestAccountLimitsClientAPI = resolve()
    ) {
        self.enabledCurrenciesService = enabledCurrenciesService
        self.client = client
    }

    // MARK: - InterestAccountLimitsRepositoryAPI

    func fetchInterestAccountLimitsForAllAssets(
        _ fiatCurrency: FiatCurrency
    ) -> AnyPublisher<[InterestAccountLimits], InterestAccountLimitsError> {
        let enabledCryptoCurrencies = enabledCurrenciesService
            .allEnabledCryptoCurrencies
        return client
            .fetchInterestAccountLimitsResponseForFiatCurrency(fiatCurrency)
            .mapError(InterestAccountLimitsError.networkError)
            .map { response -> [InterestAccountLimits] in
                enabledCryptoCurrencies
                    .compactMap { crypto -> InterestAccountLimits? in
                        guard let value = response[crypto] else { return nil }
                        return InterestAccountLimits(
                            value,
                            cryptoCurrency: crypto
                        )
                    }
            }
            .eraseToAnyPublisher()
    }

    func fetchInterestAccountLimitsForCryptoCurrency(
        _ cryptoCurrency: CryptoCurrency,
        fiatCurrency: FiatCurrency
    ) -> AnyPublisher<InterestAccountLimits, InterestAccountLimitsError> {
        fetchInterestAccountLimitsForAllAssets(fiatCurrency)
            .flatMap { interestAccountLimits
                -> AnyPublisher<InterestAccountLimits, InterestAccountLimitsError> in
                let limit = interestAccountLimits
                    .first(where: { $0.cryptoCurrency == cryptoCurrency })
                guard let limit else {
                    return .failure(.interestAccountLimitsUnavailable)
                }
                return .just(limit)
            }
            .eraseToAnyPublisher()
    }
}
