// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import MoneyKit
import PlatformKit

/// Represents transaction limits specific to a user for how much they can move in and out of Blockchain.com's custodial services.
/// It does not include limits specific to a trade.
///
/// This is meant to be used by the `TransactionLimitsRepositoryAPI` ONLY!
/// This IS NOT meant to be used by the `TransactionEngine`s to build a transaction. Use `TransactionLimitsServiceAPI` for that instead!
///
/// Use `TransactionLimits` to combine data from `TradeLimits` with `CrossBorderLimits` limits.
/// To fetch `TransactionLimits` for a specific transaction, use `TransactionLimitsServiceAPI`.
public struct CrossBorderLimits: Equatable {

    public let currency: CurrencyType
    public let currentLimits: PeriodicLimits? // nil means that there are no limits
    public let suggestedUpgrade: SuggestedLimitsUpgrade?

    public init(
        currency: CurrencyType,
        currentLimits: PeriodicLimits?,
        suggestedUpgrade: SuggestedLimitsUpgrade?
    ) {
        self.currency = currency
        self.currentLimits = currentLimits
        self.suggestedUpgrade = suggestedUpgrade
    }
}

// MARK: - Currency Conversion

extension CrossBorderLimits {

    func convert(using exchangeRate: MoneyValue) -> CrossBorderLimits {
        CrossBorderLimits(
            currency: exchangeRate.currencyType,
            currentLimits: currentLimits?.convert(using: exchangeRate),
            suggestedUpgrade: suggestedUpgrade?.convert(using: exchangeRate)
        )
    }
}
