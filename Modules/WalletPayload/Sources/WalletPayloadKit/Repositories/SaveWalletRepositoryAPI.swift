// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import Errors

public protocol SaveWalletRepositoryAPI {

    /// Save a wallet on the backend
    /// - Parameters:
    ///   - payload: A `WalletCreationPayload` containing the wallet payload
    ///   - addresses: An optional `String` in a format of `{address}|{address}`
    /// - Returns: `AnyPublisher<Void, NetworkError>`
    func saveWallet(
        payload: WalletCreationPayload,
        addresses: String?
    ) -> AnyPublisher<Void, NetworkError>
}
