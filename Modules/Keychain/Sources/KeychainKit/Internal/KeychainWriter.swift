// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

/// Types adopting the `KeychainWriterAPI` should provide write access to the keychain
protocol KeychainWriterAPI {
    /// Writes a value to the Keychain using the given query
    ///
    /// - Note: If the given key already exists then the current value
    ///         will be overridden using the new value
    ///
    /// - Parameters:
    ///   - value: A `Data` value type to be written
    ///   - key: A `String` value for the key
    func write(
        value: Data,
        for key: String
    ) -> Result<Void, KeychainWriterError>

    /// Removes a value from the Keychain
    /// - Parameter key: A `String` value for the key
    func remove(
        for key: String
    ) -> Result<Void, KeychainWriterError>
}

/// Provides write access to Keychain
final class KeychainWriter: KeychainWriterAPI {

    private let queryProvider: KeychainQueryProvider
    private let coreWriter: CoreKeychainAction
    private let coreUpdater: CoreKeychainUpdater
    private let coreRemover: CoreKeychainAction

    init(
        queryProvider: KeychainQueryProvider,
        coreWriter: @escaping CoreKeychainAction,
        coreUpdater: @escaping CoreKeychainUpdater,
        coreRemover: @escaping CoreKeychainAction
    ) {
        self.queryProvider = queryProvider
        self.coreWriter = coreWriter
        self.coreUpdater = coreUpdater
        self.coreRemover = coreRemover
    }

    @discardableResult
    func write(
        value: Data,
        for key: String
    ) -> Result<Void, KeychainWriterError> {

        var keychainQuery = queryProvider.query()
        keychainQuery[kSecAttrAccount as String] = key
        keychainQuery[kSecValueData as String] = value

        var status = coreWriter(keychainQuery as CFDictionary)

        if status == errSecDuplicateItem {
            let attributesToUpdate = [
                kSecValueData: value
            ] as CFDictionary

            status = coreUpdater(
                keychainQuery as CFDictionary,
                attributesToUpdate
            )
        }

        guard status == errSecSuccess else {
            return .failure(
                .writeFailed(
                    account: key,
                    status: status
                )
            )
        }
        return .success(())
    }

    func remove(
        for key: String
    ) -> Result<Void, KeychainWriterError> {
        let keychainQuery = queryProvider.query()

        let status = coreRemover(keychainQuery as CFDictionary)
        guard status == errSecSuccess || status == errSecItemNotFound else {
            return .failure(
                .removalFailed(
                    account: key,
                    status: status
                )
            )
        }
        return .success(())
    }
}
