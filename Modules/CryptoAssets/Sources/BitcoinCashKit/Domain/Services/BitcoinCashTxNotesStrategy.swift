// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import DIKit
import ToolKit
import WalletPayloadKit

public protocol BitcoinCashTxNotesStrategyAPI: TxNoteUpdateProvideStrategyAPI {}

final class BitcoinCashTxNotesStrategy: BitcoinCashTxNotesStrategyAPI {

    private let repository: BitcoinCashWalletAccountRepository
    private let updater: BitcoinCashEntryFetcherAPI
    private let nativeWalletFeatureEnabled: () -> AnyPublisher<Bool, Never>

    init(
        repository: BitcoinCashWalletAccountRepository,
        updater: BitcoinCashEntryFetcherAPI,
        nativeWalletFeatureEnabled: @escaping () -> AnyPublisher<Bool, Never> = { nativeWalletFlagEnabled() }
    ) {
        self.repository = repository
        self.updater = updater
        self.nativeWalletFeatureEnabled = nativeWalletFeatureEnabled
    }

    func note(
        txHash: String
    ) -> AnyPublisher<String?, TxNotesError> {
        nativeWalletFeatureEnabled()
            .flatMap { [repository] isEnabled -> AnyPublisher<String?, TxNotesError> in
                guard isEnabled else {
                    return .just(nil) // JS didn't support this
                }
                return repository.bitcoinCashEntry
                    .mapError { _ in TxNotesError.unableToRetrieveNote }
                    .compactMap { $0 }
                    .map { entry in
                        entry.txNotes?[txHash]
                    }
                    .first()
                    .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }

    func updateNote(
        txHash: String,
        note: String?
    ) -> AnyPublisher<EmptyValue, TxNotesError> {
        nativeWalletFeatureEnabled()
            .flatMap { [repository, updater] isEnabled -> AnyPublisher<EmptyValue, TxNotesError> in
                guard isEnabled else {
                    return .failure(.unabledToSave) // JS didn't support this
                }
                return repository.bitcoinCashEntry
                    .first()
                    .mapError { _ in TxNotesError.unableToRetrieveNote }
                    .compactMap { $0 }
                    .map { entry -> BitcoinCashEntry in
                        let notes = entry.txNotes
                        let updatedNotes = transcationNotesUpdate(notes: notes, hash: txHash, note: note)
                        return BitcoinCashEntry(
                            payload: entry.payload,
                            accounts: entry.accounts,
                            txNotes: updatedNotes
                        )
                    }
                    .flatMap { updatedEntry -> AnyPublisher<EmptyValue, TxNotesError> in
                        updater.update(entry: updatedEntry)
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
