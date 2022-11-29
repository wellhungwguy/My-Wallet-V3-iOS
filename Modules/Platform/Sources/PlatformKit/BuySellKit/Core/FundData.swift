// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Localization
import MoneyKit

public struct FundData: Equatable {
    /// The lesser between available amount and maximum limit.
    public let topLimit: FiatValue
    public let balance: FiatValue

    public var label: String {
        topLimit.currency.name
    }

    init(balance: CustodialAccountBalance, max: FiatValue) {
        let fiatBalance = balance.available.fiatValue!
        let useTotalBalance = (try? fiatBalance < max) ?? false
        if useTotalBalance {
            self.topLimit = fiatBalance
        } else {
            self.topLimit = max
        }
        self.balance = fiatBalance
    }
}
