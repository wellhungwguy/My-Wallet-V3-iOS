// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import Foundation
import ToolKit
import WalletPayloadKit

// Provides a transaction note, if any as `AnyPublisher<String?, WalletTxNoteError>`
public typealias BitcoinTxNoteProvider = (
    _ txHash: String
) -> AnyPublisher<String?, WalletTxNoteError>

// Updates a transaction note for a given hash, returns `AnyPublisher<EmptyValue, WalletTxNoteError>`
public typealias BitcoinTxNoteUpdater = (
    _ txHash: String,
    _ value: String?
) -> AnyPublisher<EmptyValue, WalletTxNoteError>

func bitcoinTxNoteProvider(
    txNoteProvider: @escaping BitcoinTxNoteProvider,
    bridge: BitcoinWalletBridgeAPI,
    nativeWalletFeatureFlagEnabled: () -> AnyPublisher<Bool, Never>
) -> BitcoinTxNoteProvider {
    { [bridge, txNoteProvider] txHash -> AnyPublisher<String?, WalletTxNoteError> in
        nativeWalletFlagEnabled()
            .mapError(to: WalletTxNoteError.self)
            .flatMap { isEnabled
                -> AnyPublisher<String?, WalletTxNoteError> in
                guard isEnabled else {
                    return bridge.note(for: txHash)
                        .asPublisher()
                        .mapError { _ in WalletTxNoteError.unableToRetrieveNote }
                        .eraseToAnyPublisher()
                }
                return txNoteProvider(txHash)
                    .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }
}

func bitcoinTxNoteUpdater(
    txNoteUpdater: @escaping BitcoinTxNoteUpdater,
    bridge: BitcoinWalletBridgeAPI,
    nativeWalletFeatureFlagEnabled: () -> AnyPublisher<Bool, Never>
) -> BitcoinTxNoteUpdater {
    { [bridge, txNoteUpdater] txHash, note -> AnyPublisher<EmptyValue, WalletTxNoteError> in
        nativeWalletFlagEnabled()
            .mapError(to: WalletTxNoteError.self)
            .flatMap { [bridge, txNoteUpdater] isEnabled
                -> AnyPublisher<EmptyValue, WalletTxNoteError> in
                guard isEnabled else {
                    return bridge.updateNote(for: txHash, note: note)
                        .asPublisher()
                        .mapError { _ in WalletTxNoteError.unableToRetrieveNote }
                        .map { _ in .noValue }
                        .eraseToAnyPublisher()
                }
                return txNoteUpdater(txHash, note)
                    .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }
}
