// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import DIKit
import Errors
import MoneyKit
import NetworkKit
import PlatformKit
import ToolKit

final class APIClient: InterestActivityItemEventClientAPI {

    private enum Path {
        static let activity = ["payments", "transactions"]
    }

    private enum Parameter {
        static let product = "product"
        static let currency = "currency"
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

    // MARK: - InterestActivityItemEventClientAPI

    func fetchInterestActivityItemEventsForCryptoCurrency(
        _ cryptoCurrency: CryptoCurrency
    ) -> AnyPublisher<InterestActivityResponse, NabuNetworkError> {
        let parameters = [
            URLQueryItem(
                name: Parameter.currency,
                value: cryptoCurrency.code
            ),
            URLQueryItem(
                name: Parameter.product,
                value: "savings"
            )
        ]

        let request = requestBuilder.get(
            path: Path.activity,
            parameters: parameters,
            authenticated: true
        )!

        return networkAdapter
            .perform(request: request)
    }
}
