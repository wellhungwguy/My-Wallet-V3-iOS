// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import MetadataKit
import PlatformKit

struct EthereumWallet: Equatable {
    let accounts: [EthereumWalletAccount]

    var defaultAccountIndex: Int {
        entry?.ethereum?.defaultAccountIndex ?? 0
    }

    let entry: EthereumEntryPayload?

    init(entry: EthereumEntryPayload?, accounts: [EthereumWalletAccount]) {
        self.entry = entry
        self.accounts = accounts
    }
}

public struct EthereumWalletAccount: Equatable {
    let index: Int
    public let publicKey: String
    let label: String?
    let archived: Bool

    init(
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
