// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import Foundation
import ToolKit

public enum VerifyMnemonicBackupServiceError: Error {
    case notInitialized
    case syncFailure(WalletSyncError)
}

public protocol VerifyMnemonicBackupServiceAPI {
    /// Updates the wallet's value of `verifiedMnemonic` to `true` and syncs the wallet.
    /// - Returns: `AnyPublisher<EmptyValue, VerifyMnemonicBackupServiceError>`
    func markRecoveryPhraseAndSync() -> AnyPublisher<EmptyValue, VerifyMnemonicBackupServiceError>
}

final class VerifyMnemonicBackupService: VerifyMnemonicBackupServiceAPI {

    private let walletHolder: WalletHolderAPI
    private let walletSync: WalletSyncAPI
    private let walletRepo: WalletRepoAPI
    private let logger: NativeWalletLoggerAPI

    init(
        walletHolder: WalletHolderAPI,
        walletSync: WalletSyncAPI,
        walletRepo: WalletRepoAPI,
        logger: NativeWalletLoggerAPI
    ) {
        self.walletHolder = walletHolder
        self.walletSync = walletSync
        self.walletRepo = walletRepo
        self.logger = logger
    }

    func markRecoveryPhraseAndSync() -> AnyPublisher<EmptyValue, VerifyMnemonicBackupServiceError> {
        walletHolder.walletStatePublisher
            .first()
            .zip(walletRepo.get().map(\.credentials.password))
            .mapError(to: VerifyMnemonicBackupServiceError.self)
            .flatMap { walletState, password -> AnyPublisher<(Wrapper, String), VerifyMnemonicBackupServiceError> in
                guard let wrapper = walletState?.wrapper else {
                    return .failure(.notInitialized)
                }
                return .just((wrapper, password))
            }
            .logMessageOnOutput(logger: logger) { wrapper, _ in
                "[VerifyBackup] About to update mnemonic_verified on wrapper: \(wrapper)"
            }
            .flatMap { currentWrapper, password -> AnyPublisher<(Wrapper, String), VerifyMnemonicBackupServiceError> in
                let currentWallet = currentWrapper.wallet
                let walletUpdater = markMnemonicVerified(updater: mnemonicVerifiedUpdater)
                guard let updatedWallet = walletUpdater(currentWallet) else {
                    return .failure(.notInitialized)
                }
                let updatedWrapper = updateWrapper(nativeWallet: updatedWallet)(currentWrapper)
                return .just((updatedWrapper, password))
            }
            .logMessageOnOutput(logger: logger) { wrapper, _ in
                "[VerifyBackup] Wrapper updated: \(wrapper)"
            }
            .flatMap { [walletSync] updatedWrapper, password
                -> AnyPublisher<EmptyValue, VerifyMnemonicBackupServiceError> in
                walletSync.sync(wrapper: updatedWrapper, password: password)
                    .mapError(VerifyMnemonicBackupServiceError.syncFailure)
                    .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }
}

/// Returns an new copy of `NativeWallet` with  `mnemonicVerified` of `HDWallet` set to `true`
private func markMnemonicVerified(
    updater: @escaping (HDWallet) -> HDWallet
) -> (_ currentWallet: NativeWallet) -> NativeWallet? {
    { currentWallet in
        guard let hdWallet = currentWallet.defaultHDWallet else {
            return nil
        }
        let updatedHDWallet = updater(hdWallet)
        return NativeWallet(
            guid: currentWallet.guid,
            sharedKey: currentWallet.sharedKey,
            doubleEncrypted: currentWallet.doubleEncrypted,
            doublePasswordHash: currentWallet.doublePasswordHash,
            metadataHDNode: currentWallet.metadataHDNode,
            options: currentWallet.options,
            hdWallets: [updatedHDWallet],
            addresses: currentWallet.addresses,
            txNotes: currentWallet.txNotes,
            addressBook: currentWallet.addressBook
        )
    }
}

/// Returns an updated `HDWallet` with `mnemonicVerified` set to `true`
private func mnemonicVerifiedUpdater(_ current: HDWallet) -> HDWallet {
    HDWallet(
        seedHex: current.seedHex,
        passphrase: current.passphrase,
        mnemonicVerified: true,
        defaultAccountIndex: current.defaultAccountIndex,
        accounts: current.accounts
    )
}
