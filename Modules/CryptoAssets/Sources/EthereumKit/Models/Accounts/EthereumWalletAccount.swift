// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import MetadataKit
import PlatformKit

public struct EthereumWallet: Equatable {
    public let accounts: [EthereumWalletAccount]

    public var defaultAccountIndex: Int {
        entry?.ethereum?.defaultAccountIndex ?? 0
    }

    let entry: EthereumEntryPayload?

    init(entry: EthereumEntryPayload?, accounts: [EthereumWalletAccount]) {
        self.entry = entry
        self.accounts = accounts
    }
}

public struct EthereumWalletAccount: WalletAccount, Equatable {
    public let index: Int
    public let publicKey: String
    public var label: String?
    public var archived: Bool

    public init(
        index: Int,
        publicKey: String,
        label: String?,
        archived: Bool
    ) {
        self.index = index
        self.publicKey = publicKey
        self.label = label
        self.archived = archived
    }
}

public struct LegacyEthereumWalletAccount: Codable {
    public let addr: String
    public let label: String
    public let archived: Bool

    public init(addr: String, label: String, archived: Bool) {
        self.addr = addr
        self.label = label
        self.archived = archived
    }
}
