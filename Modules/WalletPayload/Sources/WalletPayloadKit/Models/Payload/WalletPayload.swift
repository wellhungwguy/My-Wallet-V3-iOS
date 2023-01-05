// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

public struct WalletPayload: Equatable, Codable {

    public let guid: String
    public let authType: Int
    public let language: String
    public let shouldSyncPubKeys: Bool
    public let time: Date
    public var payloadWrapper: WalletPayloadWrapper?
    public let payloadChecksum: String?

    public static let empty: WalletPayload = .init(
        guid: "",
        authType: 0,
        language: "",
        shouldSyncPubKeys: false,
        time: Date(),
        payloadChecksum: "",
        payload: .init(pbkdf2IterationCount: 0, version: 0, payload: "")
    )

    public init(
        guid: String,
        authType: Int,
        language: String,
        shouldSyncPubKeys: Bool,
        time: Date,
        payloadChecksum: String?,
        payload: WalletPayloadWrapper?
    ) {
        self.guid = guid
        self.authType = authType
        self.language = language
        self.shouldSyncPubKeys = shouldSyncPubKeys
        self.time = time
        self.payloadWrapper = payload
        self.payloadChecksum = payloadChecksum
    }
}

extension WalletPayload {
    var authenticatorType: WalletAuthenticatorType {
        WalletAuthenticatorType(rawValue: authType) ?? .standard
    }
}
