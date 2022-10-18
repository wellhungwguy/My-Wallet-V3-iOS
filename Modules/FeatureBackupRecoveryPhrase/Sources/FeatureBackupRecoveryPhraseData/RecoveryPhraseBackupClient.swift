// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import DIKit
import Foundation
import NetworkKit

public protocol RecoveryPhraseBackupClientAPI {

    func updateMnemonicBackup(
        guid: String,
        sharedKey: String
    ) -> AnyPublisher<Void, NetworkError>
}

public final class RecoveryPhraseBackupClient: RecoveryPhraseBackupClientAPI {

    // MARK: - Types

    private enum Path {
        static let wallet = ["wallet"]
    }

    private enum Parameters {
        enum UpdateMnemonicBackup {
            static let method = "method"
            static let guid = "guid"
            static let sharedKey = "sharedKey"
        }
    }

    // MARK: - Properties

    private let requestBuilder: RequestBuilder
    private let networkAdapter: NetworkAdapterAPI

    // MARK: - Setup

    public init(
        networkAdapter: NetworkAdapterAPI = resolve(),
        requestBuilder: RequestBuilder = resolve(tag: DIKitContext.wallet)
    ) {
        self.networkAdapter = networkAdapter
        self.requestBuilder = requestBuilder
    }

    // MARK: - API

    public func updateMnemonicBackup(guid: String, sharedKey: String) -> AnyPublisher<Void, NetworkError> {
        let parameters = [
            URLQueryItem(
                name: Parameters.UpdateMnemonicBackup.method,
                value: "update-mnemonic-backup"
            ),
            URLQueryItem(
                name: Parameters.UpdateMnemonicBackup.guid,
                value: guid
            ),
            URLQueryItem(
                name: Parameters.UpdateMnemonicBackup.sharedKey,
                value: sharedKey
            )
        ]
        let data = RequestBuilder.body(from: parameters)
        let request = requestBuilder.post(
            path: Path.wallet,
            body: data,
            contentType: .formUrlEncoded
        )!
        return networkAdapter.perform(request: request)
    }
}
