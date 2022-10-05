// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

/// Types adopting the `KeychainReaderAPI` should provide write access to the keychain
protocol KeychainReaderAPI {

    /// Reads a value from the Keychain using the given query
    /// - Parameters:
    ///   - key: A `String` value for the key
    func read(
        for key: String
    ) -> Result<Data, KeychainReaderError>
}

/// Provides read access to Keychain
final class KeychainReader: KeychainReaderAPI {

    private let queryProvider: KeychainQueryProvider
    private let coreReader: CoreKeychainReader

    init(
        queryProvider: KeychainQueryProvider,
        coreReader: @escaping CoreKeychainReader
    ) {
        self.queryProvider = queryProvider
        self.coreReader = coreReader
    }

    func read(
        for key: String
    ) -> Result<Data, KeychainReaderError> {

        let keychainQuery = queryProvider.readOneQuery(key: key)

        let output = coreReader(
            keychainQuery as CFDictionary
        )

        guard output.status != errSecItemNotFound else {
            return .failure(
                .itemNotFound(
                    account: key
                )
            )
        }
        guard output.status == errSecSuccess else {
            return .failure(
                .readFailed(
                    account: key,
                    status: output.status
                )
            )
        }
        guard let data = output.object as? Data else {
            return .failure(
                .dataCorrupted(
                    account: key
                )
            )
        }
        return .success(data)
    }
}
