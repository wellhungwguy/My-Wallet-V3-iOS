// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import Errors
import FeatureCardIssuingDomain
import Foundation
import NetworkKit

public final class KYCClient: KYCClientAPI {

    // MARK: - Types

    private enum Path: String {
        case kyc
    }

    // MARK: - Properties

    private let networkAdapter: NetworkAdapterAPI
    private let requestBuilder: RequestBuilder

    // MARK: - Setup

    public init(
        networkAdapter: NetworkAdapterAPI,
        requestBuilder: RequestBuilder
    ) {
        self.networkAdapter = networkAdapter
        self.requestBuilder = requestBuilder
    }

    // MARK: - API

    public func update(_ parameters: KYCUpdateParameters) -> AnyPublisher<KYC, NabuNetworkError> {
        let request = requestBuilder.post(
            path: [Path.kyc.rawValue],
            body: try? parameters.encode(),
            authenticated: true
        )!

        return networkAdapter
            .perform(request: request, responseType: KYC.self)
            .eraseToAnyPublisher()
    }

    public func fetch() -> AnyPublisher<KYC, NabuNetworkError> {
        let request = requestBuilder.get(
            path: [Path.kyc.rawValue],
            authenticated: true
        )!

        return networkAdapter
            .perform(request: request, responseType: KYC.self)
            .eraseToAnyPublisher()
    }
}
