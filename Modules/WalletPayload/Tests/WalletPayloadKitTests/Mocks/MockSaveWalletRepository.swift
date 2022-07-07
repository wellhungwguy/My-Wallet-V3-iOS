// Copyright © Blockchain Luxembourg S.A. All rights reserved.

@testable import WalletPayloadDataKit
@testable import WalletPayloadKit

import Combine
import Errors

final class SaveWalletRepositoryMock: SaveWalletRepositoryAPI {
    var saveWalletCalled: Bool = false
    var payload: WalletCreationPayload?
    var addresses: String?
    var saveWalletResult: Result<Void, NetworkError> = .failure(.unknown)
    func saveWallet(
        payload: WalletCreationPayload,
        addresses: String?
    ) -> AnyPublisher<Void, NetworkError> {
        saveWalletCalled = true
        self.payload = payload
        self.addresses = addresses
        return saveWalletResult
            .publisher
            .eraseToAnyPublisher()
    }
}
