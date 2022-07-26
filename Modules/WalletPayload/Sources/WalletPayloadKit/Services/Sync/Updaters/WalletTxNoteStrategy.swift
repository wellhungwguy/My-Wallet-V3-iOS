// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import CommonCryptoKit
import Foundation
import MetadataKit
import ToolKit

public enum WalletTxNoteError: LocalizedError, Equatable {
    case notInitialized
    case unableToRetrieveNote
    case syncFailure(WalletSyncError)
}

final class WalletTxNoteStrategy: TxNoteUpdateProvideStrategyAPI {

    private let walletHolder: WalletHolderAPI
    private let walletRepo: WalletRepoAPI
    private let walletSync: WalletSyncAPI
    private let operationQueue: DispatchQueue

    init(
        walletHolder: WalletHolderAPI,
        walletRepo: WalletRepoAPI,
        walletSync: WalletSyncAPI,
        operationQueue: DispatchQueue
    ) {
        self.walletHolder = walletHolder
        self.walletRepo = walletRepo
        self.walletSync = walletSync
        self.operationQueue = operationQueue
    }

    func note(
        txHash: String
    ) -> AnyPublisher<String?, TxNotesError> {
        getWallet(walletHolder: walletHolder)
            .mapError { _ in TxNotesError.notInitialized }
            .receive(on: operationQueue)
            .map { wallet -> String? in
                guard let txNotes = wallet.txNotes else {
                    return nil
                }
                return txNotes[txHash]
            }
            .eraseToAnyPublisher()
    }

    func updateNote(
        txHash: String,
        note: String?
    ) -> AnyPublisher<EmptyValue, TxNotesError> {
        getWrapper(walletHolder: walletHolder)
            .zip(walletRepo.get().map(\.credentials.password).mapError(to: WalletError.self))
            .receive(on: operationQueue)
            .mapError { _ in TxNotesError.notInitialized }
            .map { currentWrapper, password -> (Wrapper, String) in
                let currentWallet = currentWrapper.wallet
                let walletUpdater = updateTxNotes(updater: transcationNotesUpdate, hash: txHash, note: note)
                let updatedWallet = walletUpdater(currentWallet)
                let updatedWrapper = updateWrapper(nativeWallet: updatedWallet)(currentWrapper)
                return (updatedWrapper, password)
            }
            .flatMap { [walletSync] wrapper, password -> AnyPublisher<EmptyValue, TxNotesError> in
                walletSync.sync(wrapper: wrapper, password: password)
                    .mapError(TxNotesError.syncFailure)
                    .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }
}

// MARK: - Updating methods

private func updateTxNotes(
    updater: @escaping (_ txNotes: [String: String]?, _ hash: String, _ note: String?) -> [String: String],
    hash: String,
    note: String?
) -> (_ currentWallet: NativeWallet) -> NativeWallet {
    { currentWallet in
        NativeWallet(
            guid: currentWallet.guid,
            sharedKey: currentWallet.sharedKey,
            doubleEncrypted: currentWallet.doubleEncrypted,
            doublePasswordHash: currentWallet.doublePasswordHash,
            metadataHDNode: currentWallet.metadataHDNode,
            options: currentWallet.options,
            hdWallets: currentWallet.hdWallets,
            addresses: currentWallet.addresses,
            txNotes: updater(currentWallet.txNotes, hash, note),
            addressBook: currentWallet.addressBook
        )
    }
}
