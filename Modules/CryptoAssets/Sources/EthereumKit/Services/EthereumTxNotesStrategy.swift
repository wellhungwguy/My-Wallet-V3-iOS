// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import DIKit
import MetadataKit
import ToolKit
import WalletPayloadKit

public protocol EthereumTxNotesStrategyAPI: TxNoteUpdateProvideStrategyAPI {}

final class EthereumTxNotesStrategy: EthereumTxNotesStrategyAPI {

    private let repository: EthereumWalletRepositoryAPI
    private let bridge: EthereumWalletBridgeAPI
    private let updater: WalletMetadataEntryServiceAPI
    private let nativeWalletFeatureEnabled: () -> AnyPublisher<Bool, Never>

    init(
        repository: EthereumWalletRepositoryAPI,
        bridge: EthereumWalletBridgeAPI,
        updater: WalletMetadataEntryServiceAPI,
        nativeWalletFeatureEnabled: @escaping () -> AnyPublisher<Bool, Never> = { nativeWalletFlagEnabled() }
    ) {
        self.repository = repository
        self.bridge = bridge
        self.updater = updater
        self.nativeWalletFeatureEnabled = nativeWalletFeatureEnabled
    }

    func note(
        txHash: String
    ) -> AnyPublisher<String?, TxNotesError> {
        nativeWalletFeatureEnabled()
            .flatMap { [bridge, repository] isEnabled -> AnyPublisher<String?, TxNotesError> in
                guard isEnabled else {
                    return bridge.note(for: txHash)
                        .asPublisher()
                        .mapError { _ in TxNotesError.unableToRetrieveNote }
                        .eraseToAnyPublisher()
                }
                return repository.ethereumEntry
                    .mapError { _ in TxNotesError.unableToRetrieveNote }
                    .compactMap { $0 }
                    .map { entry in
                        entry.ethereum?.transactionNotes[txHash]
                    }
                    .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }

    func updateNote(
        txHash: String,
        note: String?
    ) -> AnyPublisher<EmptyValue, TxNotesError> {
        nativeWalletFeatureEnabled()
            .flatMap { [repository, updater, bridge] isEnabled -> AnyPublisher<EmptyValue, TxNotesError> in
                guard isEnabled else {
                    return bridge.updateNote(for: txHash, note: note)
                        .asPublisher()
                        .mapError { _ in TxNotesError.unabledToSave }
                        .map { _ in .noValue }
                        .eraseToAnyPublisher()
                }
                return repository.ethereumEntry
                    .mapError { _ in TxNotesError.unableToRetrieveNote }
                    .compactMap { $0 }
                    .flatMap { entry -> AnyPublisher<EthereumEntryPayload, TxNotesError> in
                        updateEthereumEntryPayload(txHash: txHash, note: note)(entry)
                            .publisher
                            .eraseToAnyPublisher()
                    }
                    .flatMap { updatedEntry -> AnyPublisher<EmptyValue, TxNotesError> in
                        updater.save(node: updatedEntry)
                            .first()
                            .mapError { _ in TxNotesError.unabledToSave }
                            .eraseToAnyPublisher()
                    }
                    .eraseToAnyPublisher()
            }
            .handleEvents(
                receiveCompletion: { [repository] completion in
                    guard case .finished = completion else {
                        return
                    }
                    repository.invalidateCache()
                }
            )
            .eraseToAnyPublisher()
    }
}

// MARK: - Private methods

private func updateEthereumEntryPayload(
    txHash: String,
    note: String?
) -> (EthereumEntryPayload) -> Result<EthereumEntryPayload, TxNotesError> {
    { currentEntry in
        guard let ethereum = currentEntry.ethereum else {
            return .failure(.unabledToSave)
        }
        let notes = ethereum.transactionNotes
        let updatedNotes = transcationNotesUpdate(notes: notes, hash: txHash, note: note)
        let updatedEthereum = EthereumEntryPayload.Ethereum(
            accounts: ethereum.accounts,
            defaultAccountIndex: ethereum.defaultAccountIndex,
            erc20: ethereum.erc20,
            hasSeen: ethereum.hasSeen,
            lastTxTimestamp: ethereum.lastTxTimestamp,
            transactionNotes: updatedNotes
        )
        return .success(
            EthereumEntryPayload(
                ethereum: updatedEthereum
            )
        )
    }
}
