// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import Errors
import FeatureReferralDomain
import Foundation
import NetworkKit

public protocol ReferralClientAPI {
    func fetchReferralCampaign(for currency: String) -> AnyPublisher<Referral, NetworkError>
    func createReferral(with code: String) -> AnyPublisher<Void, NetworkError>
}

public struct ReferralClientClient: ReferralClientAPI {
    // MARK: - Private Properties

    private enum Path {
        static let referralInfo = ["referral", "info"]
        static let referralCreate = ["referral"]
    }

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

    public func fetchReferralCampaign(for currency: String) -> AnyPublisher<Referral, NetworkError> {
        let request = requestBuilder.get(
            path: Path.referralInfo,
            parameters: [
                URLQueryItem(name: "platform", value: "wallet"),
                URLQueryItem(name: "currency", value: currency)
            ],
            authenticated: true
        )!

        return networkAdapter
            .perform(request: request)
    }

    public func createReferral(with code: String) -> AnyPublisher<Void, NetworkError> {
        let payload = ["referralCode": code]
        let request = requestBuilder.post(
            path: Path.referralCreate,
            body: try? JSONEncoder().encode(payload),
            authenticated: true
        )!

        return networkAdapter
            .perform(request: request)
    }

    public func checkValidity() -> AnyPublisher<Bool, NetworkError> {
        let request = requestBuilder.get(
            path: Path.referralInfo,
            authenticated: true
        )!

        return networkAdapter
            .perform(request: request)
    }
}
