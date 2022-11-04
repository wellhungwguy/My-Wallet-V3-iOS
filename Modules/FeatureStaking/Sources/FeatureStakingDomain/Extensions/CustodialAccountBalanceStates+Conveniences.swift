// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import MoneyKit
import PlatformKit

extension CustodialAccountBalanceStates {
    init(balances: StakingAccountBalances) {
        let balances = balances.balances
            .reduce(into: [CurrencyType: CustodialAccountBalanceState]()) { result, item in
                guard let cryptoCurrency = CryptoCurrency(code: item.key) else {
                    return
                }
                guard let accountBalance = CustodialAccountBalance(
                    currency: cryptoCurrency.currencyType,
                    response: item.value
                ) else {
                    return
                }
                result[cryptoCurrency.currencyType] = .present(accountBalance)
            }
        self = .init(balances: balances)
    }
}
