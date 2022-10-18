// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BigInt
import FeatureWithdrawalLocksData
import Foundation
import MoneyKit
import PlatformKit

final class MoneyValueFormatterAdapter: MoneyValueFormatterAPI {

    func formatMoney(amount: String, currency: String) -> String {
        let currency = FiatCurrency(code: currency)!
        let fiatValue = FiatValue.create(minor: amount, currency: currency)!
        return fiatValue.displayString
    }
}
