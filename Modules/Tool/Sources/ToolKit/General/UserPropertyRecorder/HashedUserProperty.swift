// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

/// Should be put to use whenever a reported user property value should be hashed (identifiers)
/// The hashed used is `SHA256`
public struct HashedUserProperty: UserProperty {
    public let key: UserPropertyKey
    public let value: String
    public let truncatesValueIfNeeded: Bool

    public init(key: Key, valueHash: String, truncatesValueIfNeeded: Bool = true) {
        self.key = key
        self.value = valueHash
        self.truncatesValueIfNeeded = truncatesValueIfNeeded
    }
}

extension HashedUserProperty: Hashable {
    public static func == (lhs: HashedUserProperty, rhs: HashedUserProperty) -> Bool {
        lhs.key.rawValue == rhs.key.rawValue
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(key.rawValue)
    }
}

extension HashedUserProperty {

    /// Keys for the hashed user propertes
    public enum Key: String, UserPropertyKey {
        /// The wallet identifier
        case walletID = "wallet_id"
        /// The nabu user identifer
        case nabuID = "nabu_user_id"
    }
}
