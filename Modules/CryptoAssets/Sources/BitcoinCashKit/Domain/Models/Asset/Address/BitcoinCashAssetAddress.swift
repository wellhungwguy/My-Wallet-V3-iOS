// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import MoneyKit

public struct BitcoinCashAssetAddress: Hashable {

    public let publicKey: String
    public let cryptoCurrency: CryptoCurrency = .bitcoinCash

    public init(publicKey: String) {
        self.publicKey = publicKey
    }
}
