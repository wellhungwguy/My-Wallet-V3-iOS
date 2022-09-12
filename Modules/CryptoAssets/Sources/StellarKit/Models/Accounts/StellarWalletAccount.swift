// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import PlatformKit

struct StellarWalletAccount: Equatable {
    let index: Int
    let publicKey: String
    let label: String?
    let archived: Bool

    init(index: Int, publicKey: String, label: String? = nil, archived: Bool = false) {
        self.index = index
        self.publicKey = publicKey
        self.label = label
        self.archived = archived
    }
}
