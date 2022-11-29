// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BigInt
import FeatureWithdrawalLocksData
import Foundation
import MoneyKit
import PlatformKit

final class CryptoValueFormatterAdapter: CryptoValueFormatterAPI {

    func format(amount: String, currency: String) -> String {
        let currency = CryptoCurrency(code: currency)!
        let cryptoValue = CryptoValue.create(minor: amount, currency: currency)!
        return cryptoValue.displayString
    }
}
