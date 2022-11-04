// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import Errors
import FeatureCoinDomain
import Foundation
import MoneyKit

public struct RatesRepository: RatesRepositoryAPI {

    private let client: RatesClientAPI

    public init(_ client: RatesClientAPI) {
        self.client = client
    }

    public func fetchEarnRates(
        code: String
    ) -> AnyPublisher<EarnRates, NetworkError> {
        let stakingRatePublisher = client.fetchStakingAccountRateForCurrencyCode()
            .map { $0[code]?.rate ?? 0 }
            .eraseToAnyPublisher()
        return client.fetchInterestAccountRateForCurrencyCode(code)
            .map(\.rate)
            .zip(stakingRatePublisher)
            .map { interestRate, stakingRate in
                EarnRates(
                    stakingRate: stakingRate,
                    interestRate: interestRate
                )
            }
            .eraseToAnyPublisher()
    }
}
