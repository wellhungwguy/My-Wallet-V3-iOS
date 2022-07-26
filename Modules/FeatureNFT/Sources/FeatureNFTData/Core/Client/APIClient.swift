// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import Errors
import FeatureNFTDomain
import Foundation
import NetworkKit
import ToolKit

public protocol FeatureNFTClientAPI {
    func fetchAssetsFromEthereumAddress(
        _ address: String
    ) -> AnyPublisher<Nft, NabuNetworkError>

    func fetchAssetsFromEthereumAddress(
        _ address: String,
        pageKey: String
    ) -> AnyPublisher<Nft, NabuNetworkError>

    func registerEmailForNFTViewWaitlist(
        _ email: String
    ) -> AnyPublisher<Void, NabuNetworkError>
}

public final class APIClient: FeatureNFTClientAPI {

    private enum Path {
        static let assets = [
            "nft-market-api",
            "nft",
            "account_assets"
        ]
        static let waitlist = [
            "explorer-gateway",
            "features",
            "subscribe"
        ]
    }

    fileprivate enum Parameter {
        static let cursor = "cursor"
    }

    // MARK: - Private Properties

    private let retailRequestBuilder: RequestBuilder
    private let retailNetworkAdapter: NetworkAdapterAPI
    private let defaultRequestBuilder: RequestBuilder
    private let defaultNetworkAdapter: NetworkAdapterAPI

    // MARK: - Setup

    public init(
        retailNetworkAdapter: NetworkAdapterAPI,
        defaultNetworkAdapter: NetworkAdapterAPI,
        retailRequestBuilder: RequestBuilder,
        defaultRequestBuilder: RequestBuilder
    ) {
        self.retailNetworkAdapter = retailNetworkAdapter
        self.retailRequestBuilder = retailRequestBuilder
        self.defaultNetworkAdapter = defaultNetworkAdapter
        self.defaultRequestBuilder = defaultRequestBuilder
    }

    // MARK: - FeatureNFTClientAPI

    public func fetchAssetsFromEthereumAddress(
        _ address: String
    ) -> AnyPublisher<Nft, NabuNetworkError> {
        let request = defaultRequestBuilder.get(
            // NOTE: Space here due to backend bug
            path: Path.assets + [address],
            contentType: .json
        )!
        return defaultNetworkAdapter.perform(request: request)
    }

    public func fetchAssetsFromEthereumAddress(
        _ address: String,
        pageKey: String
    ) -> AnyPublisher<Nft, NabuNetworkError> {
        let param = URLQueryItem(
            name: Parameter.cursor,
            value: pageKey
        )
        let request = defaultRequestBuilder.get(
            path: Path.assets + [address],
            parameters: [param],
            contentType: .json
        )!
        return defaultNetworkAdapter.perform(request: request)
    }

    public func registerEmailForNFTViewWaitlist(
        _ email: String
    ) -> AnyPublisher<Void, NabuNetworkError> {
        let payload = ViewWaitlistRequest(email: email)
        let request = defaultRequestBuilder.post(
            path: Path.waitlist,
            body: try? JSONEncoder().encode(payload)
        )!
        return defaultNetworkAdapter.perform(request: request)
    }
}
