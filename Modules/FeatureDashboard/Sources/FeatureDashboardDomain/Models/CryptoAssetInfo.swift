// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation
import MoneyKit

public struct AssetBalanceInfo: Equatable, Identifiable {
    public var id: String {
        currency.code
    }

    public var hasBalance: Bool {
        fiatBalance?.quote.hasOver1UnitBalance ?? false
    }

    public let cryptoBalance: MoneyValue
    public let fiatBalance: MoneyValuePair?
    public let currency: CurrencyType
    public let delta: Decimal?

    public init(
        cryptoBalance: MoneyValue,
        fiatBalance: MoneyValuePair?,
        currency: CurrencyType,
        delta: Decimal?
    ) {
        self.cryptoBalance = cryptoBalance
        self.fiatBalance = fiatBalance
        self.currency = currency
        self.delta = delta
    }
}

extension MoneyOperating {
    public var hasOver1UnitBalance: Bool {
        (try? self >= Self.one(currency: currency)) == true
    }
}
