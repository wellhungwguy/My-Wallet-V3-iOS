// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import FeatureAuthenticationDomain
import WalletPayloadKit

final class PasswordRepository: PasswordRepositoryAPI {
    let hasPassword: AnyPublisher<Bool, Never>
    let password: AnyPublisher<String?, Never>

    private let walletRepo: WalletRepoAPI
    private let changePasswordService: ChangePasswordServiceAPI

    init(
        walletRepo: WalletRepoAPI,
        changePasswordService: ChangePasswordServiceAPI
    ) {
        self.walletRepo = walletRepo
        self.changePasswordService = changePasswordService

        password = Deferred { [walletRepo] in
            walletRepo
                .get()
                .map(\.credentials.password)
                .map { key in key.isEmpty ? nil : key }
        }
        .eraseToAnyPublisher()

        hasPassword = Deferred { [walletRepo] in
            walletRepo
                .get()
                .map(\.credentials.password)
                .map { key in !key.isEmpty }
        }
        .eraseToAnyPublisher()
    }

    func set(password: String) -> AnyPublisher<Void, Never> {
        Deferred { [walletRepo] in
            walletRepo.set(keyPath: \.credentials.password, value: password)
                .get()
                .mapToVoid()
        }
        .eraseToAnyPublisher()
    }

    func changePassword(password: String) -> AnyPublisher<Void, PasswordRepositoryError> {
        changePasswordService.change(password: password)
            .mapError { _ in
                PasswordRepositoryError.syncFailed
            }
            .eraseToAnyPublisher()
    }
}
