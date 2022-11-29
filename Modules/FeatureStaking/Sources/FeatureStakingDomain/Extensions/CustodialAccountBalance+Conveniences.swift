// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import MoneyKit
import PlatformKit

extension CustodialAccountBalance {

    init?(
        currency: CurrencyType,
        response: StakingAccountBalanceDetail
    ) {
        guard let balance = response.balance else { return nil }
        let zero: MoneyValue = .zero(currency: currency)
        let available = response.moneyBalance ?? zero
        let locked = response.lockedBalance ?? zero
        // An `Interest` account's withdrawable balance is
        // the total balance minus the locked funds.
        // This could also be called `actionableBalance`.
        let withdrawable = try? available - locked
        self.init(
            currency: currency,
            available: MoneyValue.create(minor: balance, currency: currency) ?? zero,
            withdrawable: withdrawable ?? zero,
            pending: response.moneyPendingDeposit ?? zero
        )
    }
}
