// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import Errors
import NetworkKit

public protocol OrderDomainClientAPI {

    func postOrder(
        payload: PostOrderRequest
    ) -> AnyPublisher<PostOrderResponse, NabuNetworkError>
}

public final class OrderDomainClient: OrderDomainClientAPI {

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

    public func postOrder(
        payload: PostOrderRequest
    ) -> AnyPublisher<PostOrderResponse, NabuNetworkError> {
        let request = requestBuilder.post(
            path: "/users/domain-campaigns/claim",
            body: try? payload.encode(),
            authenticated: true
        )!
        return networkAdapter.perform(request: request)
    }
}
