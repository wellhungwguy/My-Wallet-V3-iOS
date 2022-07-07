// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import FeatureAuthenticationDomain
import WalletPayloadKit

final class PasswordRepository: PasswordRepositoryAPI {
    let hasPassword: AnyPublisher<Bool, Never>
    let password: AnyPublisher<String?, Never>

    // This is set to the older WalletRepository API, soon to be removed
    private let walletRepository: WalletRepositoryAPI
    private let walletRepo: WalletRepoAPI
    private let changePasswordService: ChangePasswordServiceAPI
    private let nativeWalletEnabled: () -> AnyPublisher<Bool, Never>

    init(
        walletRepository: WalletRepositoryAPI,
        walletRepo: WalletRepoAPI,
        changePasswordService: ChangePasswordServiceAPI,
        nativeWalletEnabled: @escaping () -> AnyPublisher<Bool, Never>
    ) {
        self.walletRepository = walletRepository
        self.walletRepo = walletRepo
        self.changePasswordService = changePasswordService
        self.nativeWalletEnabled = nativeWalletEnabled

        password = nativeWalletEnabled()
            .flatMap { isEnabled -> AnyPublisher<String?, Never> in
                guard isEnabled else {
                    return walletRepository.password
                }
                return walletRepo
                    .get()
                    .map(\.credentials.password)
                    .map { key in key.isEmpty ? nil : key }
                    .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()

        hasPassword = nativeWalletEnabled()
            .flatMap { isEnabled -> AnyPublisher<Bool, Never> in
                guard isEnabled else {
                    return walletRepository.hasPassword
                }
                return walletRepo
                    .get()
                    .map(\.credentials.password)
                    .map { key in !key.isEmpty }
                    .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }

    func set(password: String) -> AnyPublisher<Void, Never> {
        walletRepository.set(password: password)
            .zip(
                walletRepo.set(keyPath: \.credentials.password, value: password).get()
            )
            .mapToVoid()
            .mapError()
            .eraseToAnyPublisher()
    }

    func changePassword(password: String) -> AnyPublisher<Void, PasswordRepositoryError> {
        nativeWalletEnabled()
            .flatMap { [walletRepository, changePasswordService] isEnabled
                -> AnyPublisher<Void, PasswordRepositoryError> in
                guard isEnabled else {
                    return walletRepository.changePassword(password: password)
                }
                return changePasswordService.change(password: password)
                    .mapError { _ in
                        PasswordRepositoryError.syncFailed
                    }
                    .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }
}
