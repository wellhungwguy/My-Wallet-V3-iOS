// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BigInt
import MoneyKit

public struct Portfolio: Codable {

    // MARK: - Types

    struct Account: Codable {
        let currency: CryptoCurrency
        let balance: String
        var cryptoValue: CryptoValue {
            CryptoValue.create(minor: balance, currency: currency) ?? .zero(currency: currency)
        }
    }

    public struct BalanceChange: Codable {
        let balance: BigInt
        public let changePercentage: Decimal
        let change: BigInt

        static let zero: BalanceChange = .init(
            balance: 0,
            changePercentage: 0.0,
            change: 0
        )
    }

    // MARK: - Public Properties

    public let balanceChange: BalanceChange
    let fiatCurrency: FiatCurrency
    public var balanceFiatValue: FiatValue {
        .create(
            minor: balanceChange.balance,
            currency: fiatCurrency
        )
    }

    public var changeFiatValue: FiatValue {
        .create(
            minor: balanceChange.change,
            currency: fiatCurrency
        )
    }

    subscript(currency: CryptoCurrency) -> Account {
        accounts[currency]!
    }

    // MARK: - Private Properties

    private var accounts: [CryptoCurrency: Account] = [:]

    // MARK: - Init

    init(
        accounts: [CryptoCurrency: Portfolio.Account],
        balanceChange: BalanceChange,
        fiatCurrency: FiatCurrency
    ) {
        self.accounts = accounts
        self.balanceChange = balanceChange
        self.fiatCurrency = fiatCurrency
    }
}
