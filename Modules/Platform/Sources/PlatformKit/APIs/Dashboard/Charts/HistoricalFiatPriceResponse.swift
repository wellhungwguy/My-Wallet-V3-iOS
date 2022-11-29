// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import MoneyKit

/// A `HistoricalFiatPriceService` response, representing the current price and the historical price series in fiat, for one crypto currency, in a given price window.
public struct HistoricalFiatPriceResponse {

    // MARK: - Public Properties

    /// The current price in fiat of the crypto currency associated with `historicalPrices`.
    ///
    /// This is **not** the `.last` value in `historicalPrices`, but rather is fetched separately from a different service.
    public let currentFiatValue: FiatValue

    /// The historical price series of the associated crypto currency.
    public let historicalPrices: HistoricalPriceSeries

    /// The price window associated with `historicalPrices`.
    public let priceWindow: PriceWindow

    // MARK: - Setup

    /// Creates a historical fiat price response.
    ///
    /// - Parameters:
    ///   - fiatValue:   The current price in fiat of the crypto currency associated with `prices`.
    ///   - prices:      A historical price series.
    ///   - priceWindow: A price window associated with `prices`.
    public init(fiatValue: FiatValue, prices: HistoricalPriceSeries, priceWindow: PriceWindow) {
        self.currentFiatValue = fiatValue
        self.historicalPrices = prices
        self.priceWindow = priceWindow
    }
}
