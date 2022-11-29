// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

public struct BitcoinCashEntryPayload: MetadataNodeEntry, Hashable {

    public enum CodingKeys: String, CodingKey {
        case accounts
        case defaultAccountIndex = "default_account_idx"
        case hasSeen = "has_seen"
        case txNotes = "tx_notes"
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

        public init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            self.archived = try container.decodeIfPresent(Bool.self, forKey: .archived) ?? false
            self.label = try container.decode(String.self, forKey: .label)
        }
    }

    public static let type: EntryType = .bitcoinCash

    public let accounts: [Account]
    public let defaultAccountIndex: Int
    public let hasSeen: Bool?
    public let txNotes: [String: String]?
    public let addresses: [String: String]?

    public init(
        accounts: [Account],
        defaultAccountIndex: Int,
        hasSeen: Bool?,
        txNotes: [String: String]?,
        addresses: [String: String]?
    ) {
        self.accounts = accounts
        self.defaultAccountIndex = defaultAccountIndex
        self.hasSeen = hasSeen
        self.txNotes = txNotes
        self.addresses = addresses
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.accounts = try container.decode([Account].self, forKey: .accounts)
        self.defaultAccountIndex = try container.decodeIfPresent(Int.self, forKey: .defaultAccountIndex) ?? 0
        self.hasSeen = try container.decodeIfPresent(Bool.self, forKey: .hasSeen)
        self.txNotes = try container.decodeIfPresent([String: String].self, forKey: .txNotes)
        self.addresses = try container.decodeIfPresent([String: String].self, forKey: .addresses)
    }
}
