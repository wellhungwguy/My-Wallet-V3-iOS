// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import DIKit
import Errors
import NetworkKit
import PlatformKit

protocol ExchangeClientAPI {
    func syncDepositAddress(
        accounts: [CryptoReceiveAddress]
    ) -> AnyPublisher<Void, NabuNetworkError>
}

final class ExchangeClient: ExchangeClientAPI {

    private let requestBuilder: RequestBuilder
    private let networkAdapter: NetworkAdapterAPI

    init(
        requestBuilder: RequestBuilder = resolve(tag: DIKitContext.retail),
        networkAdapter: NetworkAdapterAPI = resolve(tag: DIKitContext.retail)
    ) {
        self.requestBuilder = requestBuilder
        self.networkAdapter = networkAdapter
    }

    func syncDepositAddress(
        accounts: [CryptoReceiveAddress]
    ) -> AnyPublisher<Void, NabuNetworkError> {
        let payload = SyncDepositAddressRequest(accounts: accounts)
        let request = requestBuilder.post(
            path: "/users/deposit/addresses",
            body: try? JSONEncoder().encode(payload),
            authenticated: true
        )!
        return networkAdapter.perform(request: request)
    }
}

private struct SyncDepositAddressRequest: Encodable {
    let addresses: [String: String]

    init(accounts: [CryptoReceiveAddress]) {
        self.addresses = accounts
            .reduce(into: [String: String]()) { result, receiveAddress in
                result[receiveAddress.asset.code] = receiveAddress.address
            }
    }
}
