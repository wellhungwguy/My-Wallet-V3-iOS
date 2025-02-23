// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import Foundation
import NetworkKit

public protocol UserTagClientAPI {
    func updateSuperAppTag(isEnabled: Bool) -> AnyPublisher<Void, NetworkError>
}

public class UserTagClient: UserTagClientAPI {
    // MARK: - Private Properties

    private enum Path {
        static let tags = ["users", "flags", "sync"]
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

    public func updateSuperAppTag(isEnabled: Bool) -> AnyPublisher<Void, NetworkError> {
        let networkRequest = requestBuilder.patch(
            path: Path.tags,
            body: try? [
                "flags": ["superapp_mvp": isEnabled]
            ].encode(),
            authenticated: true
        )!

        return networkAdapter
            .perform(request: networkRequest)
    }
}
