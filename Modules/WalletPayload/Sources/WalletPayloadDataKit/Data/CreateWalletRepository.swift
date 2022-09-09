// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import Errors
import Foundation
import WalletPayloadKit

final class CreateWalletRepository: CreateWalletRepositoryAPI {

    private let client: CreateWalletClientAPI

    init(client: CreateWalletClientAPI) {
        self.client = client
    }

    func createWallet(
        email: String,
        payload: WalletCreationPayload,
        recaptchaToken: String?
    ) -> AnyPublisher<Void, NetworkError> {
        client.createWallet(
            email: email,
            payload: payload,
            recaptchaToken: recaptchaToken
        )
        .eraseToAnyPublisher()
    }
}
