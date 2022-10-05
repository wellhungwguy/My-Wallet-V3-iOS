// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import FeatureAuthenticationDomain
import WalletPayloadKit

final class AuthenticatorRepository: AuthenticatorRepositoryAPI {
    let authenticatorType: AnyPublisher<WalletAuthenticatorType, Never>

    private let walletRepo: WalletRepoAPI

    init(
        walletRepo: WalletRepoAPI
    ) {
        self.walletRepo = walletRepo

        authenticatorType = Deferred { [walletRepo] in
            walletRepo.get()
                .map(\.properties.authenticatorType)
        }
        .eraseToAnyPublisher()
    }

    func set(authenticatorType: WalletAuthenticatorType) -> AnyPublisher<Void, Never> {
        Deferred { [walletRepo] in
            walletRepo.set(keyPath: \.properties.authenticatorType, value: authenticatorType)
                .get()
                .mapToVoid()
        }
        .eraseToAnyPublisher()
    }
}
