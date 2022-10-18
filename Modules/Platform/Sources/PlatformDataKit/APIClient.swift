// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import DIKit
import Errors
import NetworkKit
import PlatformKit
import ToolKit

typealias PlatformDataAPIClient = InterestAccountEligibilityClientAPI &
    InterestAccountReceiveAddressClientAPI

final class APIClient: PlatformDataAPIClient {

    private enum Path {
        static let interestReceiveAddress = ["payments", "accounts", "savings"]
        static let interestEligibility = ["eligible", "product", "savings"]
        static let interestEligibleCurrencies = ["savings", "instruments"]
    }

    private enum Parameter {
        static let currency = "currency"
        static let ccy = "ccy"
    }

    // MARK: - Private Properties

    private let requestBuilder: RequestBuilder
    private let networkAdapter: NetworkAdapterAPI

    // MARK: - Setup

    init(
        networkAdapter: NetworkAdapterAPI = resolve(tag: DIKitContext.retail),
        requestBuilder: RequestBuilder = resolve(tag: DIKitContext.retail)
    ) {
        self.networkAdapter = networkAdapter
        self.requestBuilder = requestBuilder
    }

    // MARK: - InterestAccountReceiveAddressClientAPI

    func fetchInterestAccountReceiveAddressResponse(
        _ currencyCode: String
    ) -> AnyPublisher<InterestReceiveAddressResponse, NabuNetworkError> {
        let parameters = [
            URLQueryItem(
                name: Parameter.ccy,
                value: currencyCode
            )
        ]
        let request = requestBuilder.get(
            path: Path.interestReceiveAddress,
            parameters: parameters,
            authenticated: true
        )!

        return networkAdapter
            .perform(request: request)
    }

    // MARK: - InterestAccountEligibilityClientAPI

    func fetchInterestEnabledCurrenciesResponse()
        -> AnyPublisher<InterestEnabledCurrenciesResponse, NabuNetworkError>
    {
        let request = requestBuilder.get(
            path: Path.interestEligibleCurrencies,
            authenticated: true
        )!

        return networkAdapter
            .perform(request: request)
    }

    func fetchInterestAccountEligibilityResponse()
        -> AnyPublisher<InterestEligibilityResponse, NabuNetworkError>
    {
        let request = requestBuilder.get(
            path: Path.interestEligibility,
            authenticated: true
        )!

        return networkAdapter
            .perform(request: request)
    }
}
