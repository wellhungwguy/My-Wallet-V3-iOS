// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import ERC20Kit
import MoneyKit
import PlatformKit

extension ERC20TokenAccounts {

    /// Creates a stubbed ERC-20 token accounts dictionary.
    ///
    /// - Parameter cryptoCurrency: An ERC-20 crypto currency.
    ///
    /// - Returns: A stubbed ERC-20 token accounts dictionary.
    static func stubbed(cryptoCurrency: CryptoCurrency) -> ERC20TokenAccounts {
        [
            cryptoCurrency: .stubbed(cryptoCurrency: cryptoCurrency)
        ]
    }
}

extension ERC20TokenAccount {

    /// Creates a stubbed ERC-20 token account.
    ///
    /// - Parameter cryptoCurrency: An ERC-20 crypto currency.
    ///
    /// - Returns: A stubbed ERC-20 token account.
    static func stubbed(cryptoCurrency: CryptoCurrency) -> ERC20TokenAccount {
        .init(
            balance: .create(majorBigInt: 2, currency: cryptoCurrency)
        )
    }
}
