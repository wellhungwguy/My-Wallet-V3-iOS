// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import FeatureAuthenticationDomain
import WalletPayloadKit

final class SessionTokenRepository: SessionTokenRepositoryAPI {

    let sessionToken: AnyPublisher<String?, Never>

    private let walletRepo: WalletRepoAPI

    init(
        walletRepo: WalletRepoAPI
    ) {
        self.walletRepo = walletRepo

        self.sessionToken = Deferred { [walletRepo] in
            walletRepo.get()
                .map(\.credentials.sessionToken)
                .map { key in key.isEmpty ? nil : key }
        }
        .eraseToAnyPublisher()
    }

    func set(sessionToken: String) -> AnyPublisher<Void, Never> {
        Deferred { [walletRepo] in
            walletRepo.set(keyPath: \.credentials.sessionToken, value: sessionToken)
                .get()
                .mapToVoid()
        }
        .eraseToAnyPublisher()
    }

    func cleanSessionToken() -> AnyPublisher<Void, Never> {
        Deferred { [walletRepo] in
            walletRepo.set(keyPath: \.credentials.sessionToken, value: "")
                .get()
                .mapToVoid()
        }
        .eraseToAnyPublisher()
    }
}
