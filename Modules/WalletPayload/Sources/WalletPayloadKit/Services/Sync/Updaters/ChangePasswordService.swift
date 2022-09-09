// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import DIKit
import Foundation

public enum ChangePasswordError: LocalizedError {
    case syncFailed
}

public protocol ChangePasswordServiceAPI {

    /// Changes the current password and sync the `Wallet` changes to the backend
    /// - Parameter password: A `String` for the new password
    /// - Returns: `AnyPublisher<Void, ChangePasswordError>`
    func change(
        password: String
    ) -> AnyPublisher<Void, ChangePasswordError>
}

final class ChangePasswordService: ChangePasswordServiceAPI {

    private let walletSync: WalletSyncAPI
    private let walletHolder: WalletHolderAPI
    private let saveMetadataWalletCredetials: CheckAndSaveWalletCredentials
    private let logger: NativeWalletLoggerAPI

    init(
        walletSync: WalletSyncAPI,
        walletHolder: WalletHolderAPI,
        saveMetadataWalletCredetials: @escaping CheckAndSaveWalletCredentials,
        logger: NativeWalletLoggerAPI
    ) {
        self.walletSync = walletSync
        self.walletHolder = walletHolder
        self.logger = logger
        self.saveMetadataWalletCredetials = saveMetadataWalletCredetials
    }

    func change(password: String) -> AnyPublisher<Void, ChangePasswordError> {
        walletHolder.walletStatePublisher
            .first()
            .flatMap { walletState -> AnyPublisher<Wrapper, ChangePasswordError> in
                guard let wrapper = walletState?.wrapper else {
                    return .failure(.syncFailed)
                }
                return .just(wrapper)
            }
            .logMessageOnOutput(logger: logger, message: { _ in
                "[ChangePassword] About to sync wallet"
            })
            .flatMap { [walletSync] wrapper -> AnyPublisher<Wrapper, ChangePasswordError> in
                walletSync.sync(wrapper: wrapper, password: password)
                    .mapError { _ in
                        ChangePasswordError.syncFailed
                    }
                    .map { _ in wrapper }
                    .eraseToAnyPublisher()
            }
            .flatMap { [saveMetadataWalletCredetials] wrapper -> AnyPublisher<Void, ChangePasswordError> in
                saveMetadataWalletCredetials(
                    wrapper.wallet.guid,
                    wrapper.wallet.sharedKey,
                    password
                )
                .mapError(to: ChangePasswordError.self)
                .mapToVoid()
                .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }
}
