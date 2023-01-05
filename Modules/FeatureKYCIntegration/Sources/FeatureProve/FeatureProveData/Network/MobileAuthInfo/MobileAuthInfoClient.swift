// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import Errors
import Foundation
import NetworkKit

public final class MobileAuthInfoClient: MobileAuthInfoClientAPI {
    public let networkAdapter: NetworkAdapterAPI
    public let requestBuilder: RequestBuilder

    public init(
        networkAdapter: NetworkAdapterAPI,
        requestBuilder: RequestBuilder
    ) {
        self.networkAdapter = networkAdapter
        self.requestBuilder = requestBuilder
    }

    public func getMobileAuthInfo(
    ) -> AnyPublisher<MobileAuthInfoResponse, NabuError> {
        getMobileAuthInfo(body: .init())
    }

    private func getMobileAuthInfo(
        body: MobileAuthInfoRequest
    ) -> AnyPublisher<MobileAuthInfoResponse, NabuError> {
        let request = requestBuilder.post(
            path: "/mobile-auth",
            body: try? JSONEncoder().encode(body),
            authenticated: true
        )!
        return networkAdapter.perform(request: request)
    }
}
