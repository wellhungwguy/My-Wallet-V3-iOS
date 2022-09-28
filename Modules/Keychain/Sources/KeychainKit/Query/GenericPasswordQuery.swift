// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

public struct GenericPasswordQuery: KeychainQueryProvider, Equatable {
    let itemClass: KeychainItemClass = .genericPassword
    let service: String
    let accessGroup: String?
    let synchronizable: Bool

    public let permission: KeychainPermission

    public init(
        service: String
    ) {
        self.service = service
        accessGroup = nil
        permission = .whenUnlocked
        synchronizable = false
    }

    public init(
        service: String,
        accessGroup: String
    ) {
        self.service = service
        self.accessGroup = accessGroup
        permission = .whenUnlocked
        synchronizable = false
    }

    public init(
        service: String,
        accessGroup: String?,
        permission: KeychainPermission,
        synchronizable: Bool
    ) {
        self.service = service
        self.accessGroup = accessGroup
        self.permission = permission
        self.synchronizable = synchronizable
    }

    // MARK: - KeychainQuery

    public func commonQuery(key: String?, data: Data?) -> [String: Any] {
        var query = [String: Any]()
        query[kSecClass as String] = itemClass.queryValue
        query[kSecAttrService as String] = service

        if let key {
            query[kSecAttrAccount as String] = key
        }

        if let data {
            query[kSecValueData as String] = data
        }

        if synchronizable {
            query[kSecAttrSynchronizable as String] = kCFBooleanTrue
        }

        #if !targetEnvironment(simulator)
        if let accessGroup = accessGroup {
            query[kSecAttrAccessGroup as String] = accessGroup
        }
        #endif

        return query
    }

    public func writeQuery(key: String, data: Data) -> [String: Any] {
        var query = commonQuery(key: key, data: data)
        query[kSecAttrAccessible as String] = permission.queryValue
        return query
    }

    public func readOneQuery(key: String) -> [String: Any] {
        var query = commonQuery(key: key, data: nil)
        query[kSecMatchLimit as String] = kSecMatchLimitOne
        query[kSecReturnData as String] = kCFBooleanTrue
        return query
    }
}
