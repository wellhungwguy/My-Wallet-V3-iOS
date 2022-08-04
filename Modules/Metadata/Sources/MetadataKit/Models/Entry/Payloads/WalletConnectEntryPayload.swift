// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

public struct WalletConnectEntryPayload: MetadataNodeEntry, Hashable {

    public enum CodingKeys: String, CodingKey {
        case sessions
    }

    public static let type: EntryType = .walletConnect

    public let sessions: [String: [WalletConnectSession]]?

    public init(
        sessions: [String: [WalletConnectSession]]?
    ) {
        self.sessions = sessions
    }
}

public struct WalletConnectSession: Codable, Equatable, Hashable {
    public let url: String
    public let dAppInfo: DAppInfo
    public let walletInfo: WalletInfo

    public struct WalletInfo: Codable, Equatable, Hashable {
        public let clientId: String
        public let sourcePlatform: String

        public init(
            clientId: String,
            sourcePlatform: String
        ) {
            self.clientId = clientId
            self.sourcePlatform = sourcePlatform
        }
    }

    public struct DAppInfo: Codable, Equatable, Hashable {
        public let peerId: String
        public let peerMeta: ClientMeta
        public let chainId: Int?

        public init(
            peerId: String,
            peerMeta: WalletConnectSession.ClientMeta,
            chainId: Int?
        ) {
            self.peerId = peerId
            self.peerMeta = peerMeta
            self.chainId = chainId
        }
    }

    public struct ClientMeta: Codable, Equatable, Hashable {
        public let description: String
        public let url: String
        public let icons: [String]
        public let name: String

        public init(
            description: String,
            url: String,
            icons: [String],
            name: String
        ) {
            self.description = description
            self.url = url
            self.icons = icons
            self.name = name
        }
    }

    public init(
        url: String,
        dAppInfo: WalletConnectSession.DAppInfo,
        walletInfo: WalletConnectSession.WalletInfo
    ) {
        self.url = url
        self.dAppInfo = dAppInfo
        self.walletInfo = walletInfo
    }
}
