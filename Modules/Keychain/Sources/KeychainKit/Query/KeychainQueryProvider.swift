// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

public protocol KeychainQueryProvider {
    var permission: KeychainPermission { get }

    /// Returns the common attributes for a keychain query
    /// - Parameters:
    ///   - key: A `String` representing the account key
    ///   - data: A `Data`
    /// - Returns: A `Dictionary`
    func commonQuery(key: String?, data: Data?) -> [String: Any]

    /// Returns attributes for a keychain query that requires saving/storing
    /// - Parameters:
    ///   - key: A `String` representing the account key
    ///   - data: A `Data`
    /// - Returns: A `Dictionary`
    func writeQuery(key: String, data: Data) -> [String: Any]

    /// Returns attributes for a keychain query for reading an item
    ///   - key: A `String` representing the account key
    /// - Returns: A `Dictionary`
    func readOneQuery(key: String) -> [String: Any]
}
