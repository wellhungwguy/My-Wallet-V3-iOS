// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation
import MoneyKit

public struct CryptoAssetInfo: Equatable, Identifiable {
    public var id: String {
        currency.id
    }

    public var hasBalance: Bool {
        fiatBalance?.quote.hasOver1UnitBalance ?? false
    }

    public let cryptoBalance: MoneyValue
    public let fiatBalance: MoneyValuePair?
    public let currency: CryptoCurrency
    public let delta: Decimal?

    public init(
        cryptoBalance: MoneyValue,
        fiatBalance: MoneyValuePair?,
        currency: CryptoCurrency,
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
