// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import MoneyKit

public struct StakingAccountRate: Equatable {
    let cryptoCurrency: CryptoCurrency
    let rate: Double

    public init(
        cryptoCurrency: CryptoCurrency,
        rate: Double
    ) {
        self.cryptoCurrency = cryptoCurrency
        self.rate = rate
    }
}
