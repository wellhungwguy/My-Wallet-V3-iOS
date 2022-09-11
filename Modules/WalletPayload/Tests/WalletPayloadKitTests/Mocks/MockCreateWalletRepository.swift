// Copyright © Blockchain Luxembourg S.A. All rights reserved.

@testable import WalletPayloadDataKit
@testable import WalletPayloadKit

import Combine
import Errors

final class MockCreateWalletRepository: CreateWalletRepositoryAPI {

    var createWalletCalled = false
    var createWallerResult: AnyPublisher<Void, NetworkError> = .failure(.unknown)

    func createWallet(
        email: String,
        payload: WalletCreationPayload,
        recaptchaToken: String?,
        siteKey: String
    ) -> AnyPublisher<Void, NetworkError> {
        createWalletCalled = true
        return createWallerResult
    }
}
