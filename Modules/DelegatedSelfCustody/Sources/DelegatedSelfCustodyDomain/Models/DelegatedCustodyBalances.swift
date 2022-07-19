// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import MoneyKit

public struct DelegatedCustodyBalances: Equatable {
    public struct Balance: Equatable {
        let index: Int
        let name: String
        let balance: MoneyValue

        public init(index: Int, name: String, balance: MoneyValue) {
            self.index = index
            self.name = name
            self.balance = balance
        }
    }

    public let balances: [Balance]

    public func balance(index: Int, currency: CryptoCurrency) -> MoneyValue? {
        balances
            .first(where: { $0.index == index && $0.balance.currency == currency })
            .map(\.balance)
    }

    public init(balances: [DelegatedCustodyBalances.Balance]) {
        self.balances = balances
    }
}
