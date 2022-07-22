// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import Foundation
import ToolKit
import WalletPayloadKit

public protocol BitcoinTxNotesStrategyAPI: TxNoteUpdateProvideStrategyAPI {}

final class BitcoinTxNotesStrategy: BitcoinTxNotesStrategyAPI {

    private let bridge: BitcoinWalletBridgeAPI
    private let service: TxNoteUpdateProvideStrategyAPI
    private let nativeWalletFeatureFlagEnabled: () -> AnyPublisher<Bool, Never>

    init(
        bridge: BitcoinWalletBridgeAPI,
        service: TxNoteUpdateProvideStrategyAPI,
        nativeWalletFeatureFlagEnabled: @escaping () -> AnyPublisher<Bool, Never>
    ) {
        self.bridge = bridge
        self.service = service
        self.nativeWalletFeatureFlagEnabled = nativeWalletFeatureFlagEnabled
    }

    func note(txHash: String) -> AnyPublisher<String?, TxNotesError> {
        nativeWalletFlagEnabled()
            .mapError(to: TxNotesError.self)
            .flatMap { [service, bridge] isEnabled -> AnyPublisher<String?, TxNotesError> in
                guard isEnabled else {
                    return bridge.note(for: txHash)
                        .asPublisher()
                        .mapError { _ in TxNotesError.unableToRetrieveNote }
                        .eraseToAnyPublisher()
                }
                return service.note(txHash: txHash)
            }
            .eraseToAnyPublisher()
    }

    func updateNote(txHash: String, note: String?) -> AnyPublisher<EmptyValue, TxNotesError> {
        nativeWalletFlagEnabled()
            .mapError(to: TxNotesError.self)
            .flatMap { [bridge, service] isEnabled
                -> AnyPublisher<EmptyValue, TxNotesError> in
                guard isEnabled else {
                    return bridge.updateNote(for: txHash, note: note)
                        .asPublisher()
                        .mapError { _ in TxNotesError.unableToRetrieveNote }
                        .map { _ in .noValue }
                        .eraseToAnyPublisher()
                }
                return service.updateNote(txHash: txHash, note: note)
            }
            .eraseToAnyPublisher()
    }
}
