// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

/// Types adopting `KeychainAccessAPI` should provide a read and write access to the Keychain
public protocol KeychainAccessAPI {
    /// Reads a value to the Keychain using the given query
    /// - Parameters:
    ///   - key: A `String` value for the key
    func read(
        for key: String
    ) -> Result<Data, KeychainAccessError>

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
    ) -> Result<Void, KeychainAccessError>

    /// Removes a value from the Keychain
    /// - Parameter key: A `String` value for the key
    func remove(
        for key: String
    ) -> Result<Void, KeychainAccessError>

    /// Creates the KeychainAccess
    /// - Parameters:
    ///   - queryProvider: A value of `KeychainQueryProvider`
    init(queryProvider: KeychainQueryProvider)

    /// Creates the KeychainAccess with a generic password service
    /// - Parameters:
    ///   - service: A string value for the service of this Keychain item
    init(service: String)

    /// Creates the KeychainAccess with a generic password service and an accessGroup
    /// - Parameters:
    ///   - service: A string value for the service of this Keychain item
    ///   - accessGroup: A string value for the accessGroup of this Keychain item
    init(service: String, accessGroup: String)
}
