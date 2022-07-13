// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import NetworkKit

final class Client {

    enum Endpoint {
        static let balance = "/wallet-pubkey/balance"
        static let auth = "/wallet-pubkey/auth"
        static let subscriptions = "/wallet-pubkey/subscriptions"
        static let unsubscribe = "/wallet-pubkey/unsubscribe"
        static let subscribe = "/wallet-pubkey/subscribe"
        static let buildTx = "/wallet-pubkey/buildTx"
        static let pushTx = "/wallet-pubkey/pushTx"
    }

    // MARK: - Properties

    let requestBuilder: RequestBuilder
    let networkAdapter: NetworkAdapterAPI

    // MARK: - Init

    init(
        networkAdapter: NetworkAdapterAPI,
        requestBuilder: RequestBuilder
    ) {
        self.networkAdapter = networkAdapter
        self.requestBuilder = requestBuilder
    }
}
