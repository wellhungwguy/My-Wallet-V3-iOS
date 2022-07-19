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
    private let logger: NativeWalletLoggerAPI

    init(
        walletSync: WalletSyncAPI,
        walletHolder: WalletHolderAPI,
        logger: NativeWalletLoggerAPI
    ) {
        self.walletSync = walletSync
        self.walletHolder = walletHolder
        self.logger = logger
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
            .flatMap { [walletSync] wrapper -> AnyPublisher<Void, ChangePasswordError> in
                walletSync.sync(wrapper: wrapper, password: password)
                    .mapError { _ in
                        ChangePasswordError.syncFailed
                    }
                    .mapToVoid()
                    .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }
}
