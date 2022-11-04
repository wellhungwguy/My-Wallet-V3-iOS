// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import DIKit
import Errors
import MoneyKit
import NetworkKit
import PlatformKit

typealias GetStakingAllBalances = (FiatCurrency) -> AnyPublisher<StakingAccountsResponse?, NetworkError>
typealias GetStakingEligibility = () -> AnyPublisher<[String: Bool], NetworkError>
typealias GetUserRates = () -> AnyPublisher<StakingUserRatesResponse, NetworkError>

final class StakingAPIClientProvider {
    static func provideClient(
        networkAdapter: NetworkAdapterAPI,
        requestBuilder: RequestBuilder
    ) -> StakingAPIClient {
        StakingAPIClient(
            networkAdapter: networkAdapter,
            requestBuilder: requestBuilder
        )
    }
}

final class StakingAPIClient {

    private enum Path {
        static let eligible = ["earn", "eligible"]
        static let balance = ["accounts", "staking"]
        static let rates = ["earn", "rates-user"]
    }

    private enum Parameter {
        static let product = "product"
        static let currency = "currency"
        static let ccy = "ccy"
    }

    private enum ParameterValue {
        static let staking = "staking"
    }

    // MARK: - Private Properties

    private let requestBuilder: RequestBuilder
    private let networkAdapter: NetworkAdapterAPI

    // MARK: - Setup

    init(
        networkAdapter: NetworkAdapterAPI,
        requestBuilder: RequestBuilder
    ) {
        self.networkAdapter = networkAdapter
        self.requestBuilder = requestBuilder
    }

    func getAllBalances(fiatCurrency: FiatCurrency) -> AnyPublisher<StakingAccountsResponse?, NetworkError> {
        let parameters = [
            URLQueryItem(
                name: Parameter.currency,
                value: fiatCurrency.code
            )
        ]
        let request = requestBuilder.get(
            path: Path.balance,
            parameters: parameters,
            authenticated: true
        )!
        return networkAdapter
            .perform(request: request)
    }

    func getEligibility() -> AnyPublisher<[String: Bool], NetworkError> {
        let parameters = [
            URLQueryItem(
                name: Parameter.product,
                value: ParameterValue.staking
            )
        ]
        let request = requestBuilder.get(
            path: Path.eligible,
            parameters: parameters,
            authenticated: true
        )!

        return networkAdapter
            .perform(request: request)
    }

    func getUserRates() -> AnyPublisher<StakingUserRatesResponse, NetworkError> {
        let parameters = [
            URLQueryItem(
                name: Parameter.product,
                value: ParameterValue.staking
            )
        ]
        let request = requestBuilder.get(
            path: Path.rates,
            parameters: parameters,
            authenticated: true
        )!

        return networkAdapter
            .perform(request: request)
    }
}
