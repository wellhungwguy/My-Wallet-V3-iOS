// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import MoneyKit

public struct BitcoinAssetAddress: Hashable {
    public let publicKey: String
    public let cryptoCurrency: CryptoCurrency = .bitcoin

    public init(publicKey: String) {
        self.publicKey = publicKey
    }
}
