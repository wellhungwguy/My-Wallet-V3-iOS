// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

public struct BitcoinCashEntryPayload: MetadataNodeEntry, Hashable {

    public enum CodingKeys: String, CodingKey {
        case accounts
        case defaultAccountIndex = "default_account_idx"
        case hasSeen = "has_seen"
        case addresses
    }

    public struct Account: Codable, Hashable {

        public enum CodingKeys: String, CodingKey {
            case archived
            case label
        }

        public let archived: Bool
        public let label: String

        public init(
            archived: Bool,
            label: String
        ) {
            self.archived = archived
            self.label = label
        }
    }

    public static let type: EntryType = .bitcoinCash

    public let accounts: [Account]
    public let defaultAccountIndex: Int
    public let hasSeen: Bool?
    public let addresses: [String: String]? // TODO:

    public init(
        accounts: [Account],
        defaultAccountIndex: Int,
        hasSeen: Bool?,
        addresses: [String: String]?
    ) {
        self.accounts = accounts
        self.defaultAccountIndex = defaultAccountIndex
        self.hasSeen = hasSeen
        self.addresses = addresses
    }
}
