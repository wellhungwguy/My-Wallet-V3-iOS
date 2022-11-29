// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

/// Provides read and write access to Keychain
public final class KeychainAccess: KeychainAccessAPI {
    private let writer: KeychainWriterAPI
    private let reader: KeychainReaderAPI

    public init(queryProvider: KeychainQueryProvider) {
        self.reader = KeychainReader(
            queryProvider: queryProvider,
            coreReader: keychainReader
        )
        self.writer = KeychainWriter(
            queryProvider: queryProvider,
            coreWriter: keychainWriter,
            coreUpdater: keychainUpdater,
            coreRemover: keychainRemover
        )
    }

    public convenience init(service: String) {
        self.init(
            queryProvider: GenericPasswordQuery(
                service: service
            )
        )
    }

    public convenience init(service: String, accessGroup: String) {
        self.init(
            queryProvider: GenericPasswordQuery(
                service: service,
                accessGroup: accessGroup
            )
        )
    }

    // MARK: - Write methods

    @discardableResult
    public func write(
        value: Data,
        for key: String
    ) -> Result<Void, KeychainAccessError> {
        writer.write(
            value: value,
            for: key
        )
        .mapError(KeychainAccessError.writeFailure)
    }

    // MARK: - Read methods

    public func read(
        for key: String
    ) -> Result<Data, KeychainAccessError> {
        reader.read(
            for: key
        )
        .mapError(KeychainAccessError.readFailure)
    }

    // MARK: Removal Methods

    @discardableResult
    public func remove(
        for key: String
    ) -> Result<Void, KeychainAccessError> {
        writer.remove(
            for: key
        )
        .mapError(KeychainAccessError.writeFailure)
    }
}
