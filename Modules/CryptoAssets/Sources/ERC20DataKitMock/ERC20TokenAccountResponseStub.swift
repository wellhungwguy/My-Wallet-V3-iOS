// Copyright © Blockchain Luxembourg S.A. All rights reserved.

@testable import ERC20DataKit
import MoneyKit
import PlatformKit

extension ERC20TokenAccountResponse {

    /// Creates stubbed ERC-20 tokens endpoint response sub-item.
    ///
    /// - Parameter cryptoCurrency: An ERC-20 crypto currency.
    static func stubbed(cryptoCurrency: CryptoCurrency) -> ERC20TokenAccountResponse {
        .init(
            tokenHash: "ETH",
            balance: CryptoValue.create(majorBigInt: 2, currency: cryptoCurrency).minorString
        )
    }
}
