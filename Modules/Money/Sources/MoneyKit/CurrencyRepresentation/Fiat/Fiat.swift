// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

/// A fiat money.
public protocol Fiat: Money {

    /// The fiat currency.
    var currency: FiatCurrency { get }
}

extension Fiat {

    public func toDisplayString(includeSymbol: Bool, locale: Locale) -> String {
        toDisplayString(includeSymbol: includeSymbol, format: .fullLength, locale: locale)
    }

    public func toDisplayString(includeSymbol: Bool, format: NumberFormatter.CurrencyFormat) -> String {
        toDisplayString(includeSymbol: includeSymbol, format: format, locale: .current)
    }

    /// Creates a displayable string, representing the currency amount in major units, in the given locale, using the given format, optionally including the currency symbol.
    ///
    /// - Parameters:
    ///   - includeSymbol: Whether the symbol should be included.
    ///   - format                    A format.
    ///   - locale:        A locale.
    public func toDisplayString(includeSymbol: Bool, format: NumberFormatter.CurrencyFormat, locale: Locale) -> String {
        let maxFractionDigits: Int
        switch format {
        case .fullLength:
            maxFractionDigits = currency.precision
        case .shortened where displayMajorValue.exponent < 0:
            // Has a fractional part only when the exponent is negative.
            maxFractionDigits = currency.precision
        case .shortened:
            maxFractionDigits = 0
        }

        return FiatFormatterProvider.shared
            .formatter(locale: locale, fiatCurrency: currency, maxFractionDigits: maxFractionDigits)
            .format(major: displayMajorValue, includeSymbol: includeSymbol)
    }
}
