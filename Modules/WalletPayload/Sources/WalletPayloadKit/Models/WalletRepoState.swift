// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

/// Holds the storage for wallet related access
public struct WalletRepoState: Equatable, Codable {

    /// Stores credential related properties
    public var credentials: WalletCredentials

    /// Stores informational related properties
    public var properties: WalletProperties

    /// Returns the wallet payload
    public var walletPayload: WalletPayload

    /// Provides an empty state
    public static let empty = WalletRepoState(
        credentials: .empty,
        properties: .empty,
        walletPayload: .empty
    )
}

/// Holds credential information regarding the wallet
public struct WalletCredentials: Equatable, Codable {
    /// Returns the stored wallet identifier
    public var guid: String

    /// Returns the stored wallet shared key
    public var sharedKey: String

    /// Returns the stored session token
    public var sessionToken: String

    /// Returns the in-memory stored password
    /// - NOTE: for security reasons this is not stored in the keychain
    public var password: String

    static let empty = WalletCredentials(
        guid: "",
        sharedKey: "",
        sessionToken: "",
        password: ""
    )

    enum CodingKeys: String, CodingKey {
        case guid
        case sharedKey
        case sessionToken
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.guid = try container.decode(String.self, forKey: .guid)
        self.sharedKey = try container.decode(String.self, forKey: .sharedKey)
        self.sessionToken = try container.decode(String.self, forKey: .sessionToken)
        self.password = "" // we can't decode this since we don't encode it
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(guid, forKey: .guid)
        try container.encode(sharedKey, forKey: .sharedKey)
        try container.encode(sessionToken, forKey: .sessionToken)
    }

    public init(
        guid: String,
        sharedKey: String,
        sessionToken: String,
        password: String
    ) {
        self.guid = guid
        self.sharedKey = sharedKey
        self.sessionToken = sessionToken
        self.password = password
    }
}

/// Holds informational properties regarding the wallet
public struct WalletProperties: Equatable, Codable {
    /// Returns `true` if the pub keys should be synchronised
    public var syncPubKeys: Bool

    // Returns the language as specified by the wallet
    public var language: String

    /// Returns the authenticator type, of the wallet
    public var authenticatorType: WalletAuthenticatorType

    static let empty = WalletProperties(
        syncPubKeys: false,
        language: "",
        authenticatorType: .standard
    )
}
