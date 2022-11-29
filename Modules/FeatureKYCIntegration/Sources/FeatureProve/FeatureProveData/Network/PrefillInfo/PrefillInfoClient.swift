// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import Errors
import Foundation
import NetworkKit

public final class PrefillInfoClient: PrefillInfoClientAPI {
    public let networkAdapter: NetworkAdapterAPI
    public let requestBuilder: RequestBuilder

    public init(
        networkAdapter: NetworkAdapterAPI,
        requestBuilder: RequestBuilder
    ) {
        self.networkAdapter = networkAdapter
        self.requestBuilder = requestBuilder
    }

    public func getPrefillInfo(
        dateOfBirth: Date
    ) -> AnyPublisher<PrefillInfoResponse, NabuError> {
        getPrefillInfo(body: .init(dateOfBirth: dateOfBirth))
    }

    private func getPrefillInfo(
        body: PrefillInfoRequest
    ) -> AnyPublisher<PrefillInfoResponse, NabuError> {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .formatted(DateFormatter.birthday)
        let request = requestBuilder.post(
            path: "/personal-info",
            body: try? encoder.encode(body),
            authenticated: true
        )!
        return networkAdapter.perform(request: request)
    }
}
