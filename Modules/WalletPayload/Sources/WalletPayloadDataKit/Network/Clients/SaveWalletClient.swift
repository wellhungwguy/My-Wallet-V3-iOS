// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import Foundation
import NetworkKit
import WalletPayloadKit

protocol SaveWalletClientAPI {
    func saveWallet(
        payload: WalletCreationPayload,
        addresses: String?
    ) -> AnyPublisher<Void, NetworkError>
}

final class SaveWalletClient: SaveWalletClientAPI {
    private let networkAdapter: NetworkAdapterAPI
    private let requestBuilder: RequestBuilder
    private let apiCodeProvider: () -> String

    init(
        networkAdapter: NetworkAdapterAPI,
        requestBuilder: RequestBuilder,
        apiCodeProvider: @escaping () -> String
    ) {
        self.networkAdapter = networkAdapter
        self.requestBuilder = requestBuilder
        self.apiCodeProvider = apiCodeProvider
    }

    func saveWallet(
        payload: WalletCreationPayload,
        addresses: String?
    ) -> AnyPublisher<Void, NetworkError> {
        let parameters = provideDefaultParameters(
            time: Int(Date().timeIntervalSince1970 * 1000.0)
        )
        var wrapperParameters = provideWrapperParameters(from: payload)
        if let addresses {
            wrapperParameters.append(
                URLQueryItem(
                    name: "active",
                    value: addresses
                )
            )
        }
        let body = RequestBuilder.body(from: parameters + wrapperParameters)
        let request = requestBuilder.post(
            path: ["wallet"],
            body: body,
            contentType: .formUrlEncoded
        )!
        return networkAdapter.perform(request: request)
    }

    private func provideDefaultParameters(time: Int) -> [URLQueryItem] {
        [
            URLQueryItem(
                name: "method",
                value: "update"
            ),
            URLQueryItem(
                name: "format",
                value: "plain"
            ),
            URLQueryItem(
                name: "ct",
                value: String(time)
            ),
            URLQueryItem(
                name: "api_code",
                value: apiCodeProvider()
            )
        ]
    }

    private func provideWrapperParameters(
        from payload: WalletCreationPayload
    ) -> [URLQueryItem] {
        [
            URLQueryItem(
                name: "guid",
                value: payload.guid
            ),
            URLQueryItem(
                name: "sharedKey",
                value: payload.sharedKey
            ),
            URLQueryItem(
                name: "checksum",
                value: payload.checksum
            ),
            URLQueryItem(
                name: "language",
                value: payload.language
            ),
            URLQueryItem(
                name: "length",
                value: String(payload.length)
            ),
            URLQueryItem(
                name: "old_checksum",
                value: payload.oldChecksum
            ),
            URLQueryItem(
                name: "payload",
                value: String(decoding: payload.innerPayload, as: UTF8.self)
            )
        ]
    }
}
