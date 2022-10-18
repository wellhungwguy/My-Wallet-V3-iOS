// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import Errors
import Foundation
import NetworkKit

public protocol ClaimEligibilityClientAPI {

    func getEligibility() -> AnyPublisher<ClaimEligibilityResponse, NabuNetworkError>
}

public final class ClaimEligibilityClient: ClaimEligibilityClientAPI {

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

    public func getEligibility() -> AnyPublisher<ClaimEligibilityResponse, NabuNetworkError> {
        let parameters = [
            URLQueryItem(
                name: "domainCampaign",
                value: Constants.udDomainCampaign.rawValue
            )
        ]
        let request = requestBuilder.get(
            path: "/users/domain-campaigns/eligibility",
            parameters: parameters,
            authenticated: true
        )!
        return networkAdapter.perform(request: request)
    }
}

enum Constants: String {
    case udDomainCampaign = "UNSTOPPABLE_DOMAINS"
}
