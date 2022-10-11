// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import DIKit
import NetworkKit

protocol SupportedAssetsClientAPI {
    var custodialAssets: AnyPublisher<SupportedAssetsResponse, NetworkError> { get }
    var ethereumERC20Assets: AnyPublisher<SupportedAssetsResponse, NetworkError> { get }
    var otherERC20Assets: AnyPublisher<SupportedAssetsResponse, NetworkError> { get }
}

final class SupportedAssetsClient: SupportedAssetsClientAPI {

    // MARK: Types

    private enum Endpoint {
        static var coin: [String] { ["assets", "currencies", "coin"] }
        static var custodial: [String] { ["assets", "currencies", "custodial"] }
        static var ethereumERC20: [String] { ["assets", "currencies", "erc20"] }
        static var otherERC20: [String] { ["assets", "currencies", "other_erc20"] }
    }

    // MARK: Properties

    var custodialAssets: AnyPublisher<SupportedAssetsResponse, NetworkError> {
        networkAdapter.perform(
            request: requestBuilder.get(path: Endpoint.custodial)!
        )
    }

    var ethereumERC20Assets: AnyPublisher<SupportedAssetsResponse, NetworkError> {
        networkAdapter.perform(
            request: requestBuilder.get(path: Endpoint.ethereumERC20)!
        )
    }

    var otherERC20Assets: AnyPublisher<SupportedAssetsResponse, NetworkError> {
        networkAdapter.perform(
            request: requestBuilder.get(path: Endpoint.otherERC20)!
        )
    }

    // MARK: Private Properties

    private let requestBuilder: RequestBuilder
    private let networkAdapter: NetworkAdapterAPI

    // MARK: Init

    init(
        requestBuilder: RequestBuilder = resolve(),
        networkAdapter: NetworkAdapterAPI = resolve()
    ) {
        self.requestBuilder = requestBuilder
        self.networkAdapter = networkAdapter
    }
}
