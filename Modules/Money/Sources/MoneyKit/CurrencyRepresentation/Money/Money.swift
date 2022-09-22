// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BigInt
import Foundation

public protocol Money: CustomDebugStringConvertible {

    /// The currency (`FiatCurrency` or `CryptoCurrency`) wrapped in a `CurrencyType`.
    var currencyType: CurrencyType { get }

    /// The currency amount in minor units (the smallest unit of the respective currency - e.g. `cent` for `USD`, `Satoshi` for `BTC`, etc.).
    var amount: BigInt { get }

    /// The currency code (e.g. `USD`, `BTC`, etc.).
    var code: String { get }

    /// The currency display code (e.g. `USD`, `BTC`, etc.).
    var displayCode: String { get }

    /// The currency symbol (e.g. `$`, `BTC`).
    var displaySymbol: String { get }

    /// The currency precision.
    var precision: Int { get }

    /// The currency display precision.
    var displayPrecision: Int { get }

    /// Whether the amount is zero.
    var isZero: Bool { get }

    /// Whether the amount is positive.
    var isPositive: Bool { get }

    /// Whether the amount is negative.
    var isNegative: Bool { get }

    /// The currency amount in minor units, as a `String`.
    var minorString: String { get }

    /// The currency amount in major units, as a `String`, in the current locale, including the currency symbol.
    var displayString: String { get }

    /// The currency amount in major units, as a `Decimal`, truncated to `decimalPlaces`.
    var displayMajorValue: Decimal { get }

    /// Creates a displayable string, representing the currency amount in major units, in the given locale, including the currency symbol.
    ///
    /// - Parameter locale: A locale.
    func toDisplayString(locale: Locale) -> String

    /// Creates a displayable string, representing the currency amount in major units, in the current locale, optionally including the currency symbol.
    ///
    /// - Parameter includeSymbol: Whether the symbol should be included.
    func toDisplayString(includeSymbol: Bool) -> String

    /// Creates a displayable string, representing the currency amount in major units, in the given locale, optionally including the currency symbol.
    ///
    /// - Parameters:
    ///   - includeSymbol: Whether the symbol should be included.
    ///   - locale:        A locale.
    func toDisplayString(includeSymbol: Bool, locale: Locale) -> String
}

extension Money {

    public var code: String {
        currencyType.code
    }

    public var displayCode: String {
        currencyType.displayCode
    }

    public var displaySymbol: String {
        currencyType.displaySymbol
    }

    public var precision: Int {
        currencyType.precision
    }

    public var displayPrecision: Int {
        currencyType.displayPrecision
    }

    public var isZero: Bool {
        amount.isZero
    }

    public var isNotZero: Bool {
        !amount.isZero
    }

    public var isPositive: Bool {
        amount > 0
    }

    public var isNegative: Bool {
        amount < 0
    }

    public var minorString: String {
        amount.description
    }

    public var displayString: String {
        toDisplayString(includeSymbol: true)
    }

    /// Used for analytics purposes only, for other things use `displayString` instead.
    public var displayMajorValue: Decimal {
        amount.toDecimalMajor(
            baseDecimalPlaces: currencyType.precision,
            roundingDecimalPlaces: currencyType.precision
        )
    }

    public func toDisplayString(locale: Locale) -> String {
        toDisplayString(includeSymbol: true, locale: locale)
    }

    public func toDisplayString(includeSymbol: Bool) -> String {
        toDisplayString(includeSymbol: includeSymbol, locale: Locale.current)
    }

    public var debugDescription: String {
        "\(type(of: self)) \(code) \(displayString)"
    }
}
