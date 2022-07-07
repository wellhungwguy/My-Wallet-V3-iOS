// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import Foundation
import KeychainKit
import ToolKit

public enum WalletRepoPersistenceError: Error, Equatable {
    case keychainFailure(KeychainAccessError)
    case decodingFailed(WalletRepoStateCodingError)
}

public protocol WalletRepoPersistenceAPI {
    /// Begins the internal persist operation by monitor changes in the `WalletRepo`
    /// - Returns: A publisher of type `AnyPublisher<EmptyValue, WalletPersistenceError>`
    func beginPersisting() -> AnyPublisher<EmptyValue, WalletRepoPersistenceError>

    /// Retrieves the `WalletStorageState` from the `Keychain` as `AnyPublisher`
    /// - Returns: An `AnyPublisher<WalletRepoState, WalletPersistenceError>`
    func retrieve() -> AnyPublisher<WalletRepoState, WalletRepoPersistenceError>

    /// Deletes `WalletRepo` value from Keychain
    /// - Returns: A publisher of type `AnyPublisher<EmptyValue, WalletPersistenceError>`
    func delete() -> AnyPublisher<EmptyValue, WalletRepoPersistenceError>
}
