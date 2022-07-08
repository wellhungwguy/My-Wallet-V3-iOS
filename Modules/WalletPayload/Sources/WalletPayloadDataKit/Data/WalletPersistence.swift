// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import Foundation
import KeychainKit
import ToolKit
import WalletPayloadKit

/// An object responsible for observing changes from `WalletStorage` and persisting them.
final class WalletRepoPersistence: WalletRepoPersistenceAPI {

    enum KeychainAccessKey {
        static let walletState = "wallet-repo-state"
    }

    private let repo: WalletRepoAPI
    private let keychainAccess: KeychainAccessAPI
    private let persistenceQueue: DispatchQueue
    private let encoder: WalletRepoStateEncoding
    private let decoder: WalletRepoStateDecoding

    init(
        repo: WalletRepoAPI,
        keychainAccess: KeychainAccessAPI,
        queue: DispatchQueue,
        encoder: @escaping WalletRepoStateEncoding = walletRepoStateEncoder,
        decoder: @escaping WalletRepoStateDecoding = walletRepoStateDecoder
    ) {
        self.repo = repo
        self.keychainAccess = keychainAccess
        self.encoder = encoder
        self.decoder = decoder
        persistenceQueue = queue
    }

    func beginPersisting() -> AnyPublisher<EmptyValue, WalletRepoPersistenceError> {
        repo
            .stream()
            .removeDuplicates()
            .setFailureType(to: WalletRepoPersistenceError.self)
            .receive(on: persistenceQueue)
            .flatMap { [encoder] state in
                encoder(state)
                    .publisher
                    .mapError(WalletRepoPersistenceError.decodingFailed)
            }
            .flatMap { [keychainAccess] data in
                keychainAccess
                    .write(value: data, for: KeychainAccessKey.walletState)
                    .publisher
                    .mapError(WalletRepoPersistenceError.keychainFailure)
                    .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }

    func retrieve() -> AnyPublisher<WalletRepoState, WalletRepoPersistenceError> {
        keychainAccess.read(for: KeychainAccessKey.walletState)
            .mapError(WalletRepoPersistenceError.keychainFailure)
            .publisher
            .receive(on: persistenceQueue)
            .flatMap { [decoder] data -> AnyPublisher<WalletRepoState, WalletRepoPersistenceError> in
                decoder(data)
                    .mapError(WalletRepoPersistenceError.decodingFailed)
                    .publisher
                    .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }

    func delete() -> AnyPublisher<EmptyValue, WalletRepoPersistenceError> {
        Deferred { [keychainAccess] in
            Future { promise in
                let removalResult = keychainAccess.remove(for: KeychainAccessKey.walletState)
                switch removalResult {
                case .success:
                    promise(.success(.noValue))
                case .failure(let error):
                    promise(.failure(WalletRepoPersistenceError.keychainFailure(error)))
                }
            }
        }
        .eraseToAnyPublisher()
    }
}

// MARK: - Global Retrieval Method

/// Retrieves the `WalletStorageState` from the `Keychain`
/// - Returns: A previously stored `WalletStorageState` or an default empty state
func retrieveWalletRepoState(
    keychainAccess: KeychainAccessAPI,
    decoder: WalletRepoStateDecoding = walletRepoStateDecoder
) -> WalletRepoState? {
    let readResult = keychainAccess.read(for: WalletRepoPersistence.KeychainAccessKey.walletState)
    guard case .success(let data) = readResult else {
        return nil
    }
    guard case .success(let state) = decoder(data) else {
        return nil
    }
    return state
}

func walletRepoStateEncoder(
    _ value: WalletRepoState
) -> Result<Data, WalletRepoStateCodingError> {
    Result {
        try JSONEncoder().encode(value)
    }
    .mapError(WalletRepoStateCodingError.encodingFailed)
}

func walletRepoStateDecoder(
    _ data: Data
) -> Result<WalletRepoState, WalletRepoStateCodingError> {
    Result {
        try JSONDecoder().decode(WalletRepoState.self, from: data)
    }
    .mapError(WalletRepoStateCodingError.decodingFailed)
}
