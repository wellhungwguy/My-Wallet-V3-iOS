// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import DIKit
import Errors
import FeatureAuthenticationDomain
import Foundation
import NetworkKit

public final class SignUpCountriesClient: SignUpCountriesClientAPI {

    // MARK: - Types

    private enum Path {
        static let countries = ["countries"]
    }

    // MARK: - Properties

    public var countries: AnyPublisher<[Country], NabuNetworkError> {
        let request = requestBuilder.get(
            path: Path.countries,
            parameters: [URLQueryItem(name: "scope", value: "SIGNUP")]
        )!
        return networkAdapter.perform(
            request: request,
            responseType: [Country].self
        )
    }

    // MARK: - Properties

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
}
