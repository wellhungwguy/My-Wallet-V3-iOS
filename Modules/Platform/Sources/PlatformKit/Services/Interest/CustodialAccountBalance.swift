// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import MoneyKit

public struct CustodialAccountBalance: Equatable {

    public let currency: CurrencyType
    public let available: MoneyValue
    public let pending: MoneyValue
    public let withdrawable: MoneyValue
    public let mainBalanceToDisplay: MoneyValue

    public init(
        currency: CurrencyType,
        available: MoneyValue,
        withdrawable: MoneyValue,
        pending: MoneyValue,
        mainBalanceToDisplay: MoneyValue
    ) {
        self.currency = currency
        self.available = available
        self.withdrawable = withdrawable
        self.pending = pending
        self.mainBalanceToDisplay = mainBalanceToDisplay
    }

    init(currency: CurrencyType, response: CustodialBalanceResponse.Balance) {
        let zero: MoneyValue = .zero(currency: currency)
        self.currency = currency
        self.available = MoneyValue.create(minor: response.available, currency: currency) ?? zero
        self.pending = MoneyValue.create(minor: response.pending, currency: currency) ?? zero
        self.withdrawable = MoneyValue.create(minor: response.withdrawable, currency: currency) ?? zero
        if let mainBalanceToDisplay = response.mainBalanceToDisplay {
            self.mainBalanceToDisplay = MoneyValue.create(
                minor: mainBalanceToDisplay,
                currency: currency
            ) ?? zero
        } else {
            self.mainBalanceToDisplay = zero
        }
    }
}

extension CustodialAccountBalance {
    public static func zero(currencyType: CurrencyType) -> CustodialAccountBalance {
        .init(currency: currencyType, response: .zero)
    }
}
