// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import Foundation
import MetadataKit
import ToolKit

public enum TxNotesError: LocalizedError {
    case notInitialized
    case unableToRetrieveNote
    case unabledToSave
    case syncFailure(WalletSyncError)
    case metadataSaveFailure(WalletAssetSaveError)
}

public protocol TxNoteUpdateProvideStrategyAPI {
    /// Provides a note for a given transaction hash
    /// - Note: **The operations occur on a background thread.**
    /// - Parameter txHash: A `String` value
    /// - Returns: `AnyPublisher<String?, TxNotesError>`
    func note(txHash: String) -> AnyPublisher<String?, TxNotesError>

    /// Updates a note for the given transaction hash
    /// - Note: **The operations occur on a background thread.**
    /// - Parameters:
    ///   - txHash: A `String` value
    ///   - value: An optional `String` value
    /// - Returns: `AnyPublisher<EmptyValue, WalletTxNoteError>`
    func updateNote(txHash: String, note: String?) -> AnyPublisher<EmptyValue, TxNotesError>
}

// MARK: - Helper methods

/// Updates a given `Dictionary<String, String>`
/// - Parameters:
///   - notes: A `Dictionary<String, String>`
///   - hash: A `String` to be used as the key
///   - note: A `String` to be used as the value
/// - Returns: A `Dictionary<String, String>`
public func transcationNotesUpdate(
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
