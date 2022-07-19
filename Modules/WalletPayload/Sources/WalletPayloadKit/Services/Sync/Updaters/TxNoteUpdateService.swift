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

public protocol WalletTxNoteServiceAPI {
    /// Provides a note for a given transaction hash
    /// - Note: **The operations occur on a background thread.**
    /// - Parameter txHash: A `String` value
    /// - Returns: `AnyPublisher<String?, WalletTxNoteError>`
    func note(
        txHash: String
    ) -> AnyPublisher<String?, WalletTxNoteError>

    /// Updates a note for the given transaction hash
    /// - Note: **The operations occur on a background thread.**
    /// - Parameters:
    ///   - txHash: A `String` value
    ///   - value: An optional `String` value
    /// - Returns: `AnyPublisher<EmptyValue, WalletTxNoteError>`
   func updateNote(
       txHash: String,
       value: String?
   ) -> AnyPublisher<EmptyValue, WalletTxNoteError>
}

final class WalletTxNoteService: WalletTxNoteServiceAPI {

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
    ) -> AnyPublisher<String?, WalletTxNoteError> {
        getWallet(walletHolder: walletHolder)
            .mapError { _ in WalletTxNoteError.notInitialized }
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
        value: String?
    ) -> AnyPublisher<EmptyValue, WalletTxNoteError> {
        getWrapper(walletHolder: walletHolder)
            .zip(walletRepo.get().map(\.credentials.password).mapError(to: WalletError.self))
            .receive(on: operationQueue)
            .mapError { _ in WalletTxNoteError.notInitialized }
            .map { currentWrapper, password -> (Wrapper, String) in
                let currentWallet = currentWrapper.wallet
                let walletUpdater = updateTxNotes(updater: transcationNotesUpdate, hash: txHash, note: value)
                let updatedWallet = walletUpdater(currentWallet)
                let updatedWrapper = updateWrapper(nativeWallet: updatedWallet)(currentWrapper)
                return (updatedWrapper, password)
            }
            .flatMap { [walletSync] wrapper, password -> AnyPublisher<EmptyValue, WalletTxNoteError> in
                walletSync.sync(wrapper: wrapper, password: password)
                    .mapError(WalletTxNoteError.syncFailure)
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

func transcationNotesUpdate(
    notes: [String: String]?,
    hash: String,
    note: String?
) -> [String: String] {
    guard let notes = notes else {
        guard let note = note else {
            return [:]
        }
        return [hash: note]
    }
    var updatedNotes: [String: String] = notes
    // deletion will occur when `note` is `nil`
    updatedNotes[hash] = note
    return updatedNotes
}
