// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import Errors
import Foundation
import NetworkKit

public final class FlowKYCInfoClient: FlowKYCInfoClientAPI {
    public let networkAdapter: NetworkAdapterAPI
    public let requestBuilder: RequestBuilder

    public init(
        networkAdapter: NetworkAdapterAPI,
        requestBuilder: RequestBuilder
    ) {
        self.networkAdapter = networkAdapter
        self.requestBuilder = requestBuilder
    }

    public func getKYCFlowInfo() -> AnyPublisher<FlowKYCInfoClientResponse, Errors.NabuError> {
        getKYCFlowInfo(body: .init())
    }

    private func getKYCFlowInfo(
        body: FlowKYCInfoClientRequest
    ) -> AnyPublisher<FlowKYCInfoClientResponse, NabuError> {
        let request = requestBuilder.post(
            path: "/flows/kyc",
            body: try? JSONEncoder().encode(body),
            authenticated: true
        )!
        return networkAdapter.perform(request: request)
    }
}
