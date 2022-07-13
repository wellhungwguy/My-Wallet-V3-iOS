// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import Errors
import FeatureProductsDomain
import Foundation
import NetworkKit

public protocol ProductsClientAPI {

    func fetchProductsData() -> AnyPublisher<ProductsAPIResponse, NabuNetworkError>
}

public final class ProductsAPIClient: ProductsClientAPI {

    private enum Path {
        static let products: [String] = ["products"]
    }

    public let networkAdapter: NetworkAdapterAPI
    public let requestBuilder: RequestBuilder

    public init(networkAdapter: NetworkAdapterAPI, requestBuilder: RequestBuilder) {
        self.networkAdapter = networkAdapter
        self.requestBuilder = requestBuilder
    }

    public func fetchProductsData() -> AnyPublisher<ProductsAPIResponse, NabuNetworkError> {
        let queryItem = URLQueryItem(name: "product", value: "SIMPLEBUY")
        let request = requestBuilder.get(
            path: Path.products,
            parameters: [queryItem],
            authenticated: true
        )!
        return networkAdapter.perform(request: request)
    }
}
