// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BigInt
import DelegatedSelfCustodyDomain
import MoneyKit

extension DelegatedCustodyBalances {
    init(response: BalanceResponse, enabledCurrenciesService: EnabledCurrenciesServiceAPI) {
        let balances = response.currencies
            .compactMap { entry -> DelegatedCustodyBalances.Balance? in
                guard let currency = CryptoCurrency(
                    code: entry.ticker,
                    enabledCurrenciesService: enabledCurrenciesService
                ) else {
                    return nil
                }
                guard let balance = MoneyValue.create(
                    minor: entry.amount.amount,
                    currency: .crypto(currency)
                ) else {
                    return nil
                }
                return Balance(
                    index: entry.account.index,
                    name: entry.account.name,
                    balance: balance
                )
            }
        self.init(balances: balances)
    }
}
