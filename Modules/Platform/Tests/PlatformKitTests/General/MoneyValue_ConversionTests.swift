// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BigInt
import MoneyKit
import XCTest

final class MoneyValueConversionTests: XCTestCase {

    func test_converts_from_self_to_value_with_different_base_same_quote_currency() throws {
        // GIVEN: You want to convert 10 USD using a conversion rate of 1 USD = 0.00003357 BTC.
        let amount = MoneyValue.create(minor: 1000, currency: .fiat(.USD))
        let exchangeRate = MoneyValuePair(
            base: .one(currency: .USD),
            exchangeRate: MoneyValue.create(
                minor: BigInt(3357),
                currency: .crypto(.bitcoin)
            )
        )
        // WHEN: The amount is converted
        let convertedAmount = try amount.convert(using: exchangeRate)
        // THEN: The resulting amount should be 0.0003357 BTC USD (10 * 0.00003357).
        XCTAssertEqual(convertedAmount.displayString, "0.0003357 BTC")
    }

    func test_converts_from_self_to_value_with_same_base() throws {
        // GIVEN: You want to convert 10 USD using a conversion rate of 0.00003357 BTC = 1 USD.
        let amount = MoneyValue.create(minor: 1000, currency: .fiat(.USD))
        let exchangeRate = MoneyValuePair(
            base: MoneyValue.create(
                minor: BigInt(3357),
                currency: .crypto(.bitcoin)
            ),
            exchangeRate: .one(currency: .USD)
        )
        // WHEN: The amount is converted
        let convertedAmount = try amount.convert(using: exchangeRate)
        // THEN: The returned amount should be equal to the input amount as the quote is already in USD.
        XCTAssertEqual(amount, convertedAmount)
        XCTAssertEqual(convertedAmount.displayString, "$10.00")
    }

    func test_converts_from_self_to_value_with_different_base_different_quote_currency() throws {
        // GIVEN: You want to convert 10 USD using a conversion rate of 1 EUR = 0.00003357 BTC.
        let amount = MoneyValue.create(minor: 1000, currency: .fiat(.USD))
        let exchangeRate = MoneyValuePair(
            base: .one(currency: .EUR),
            exchangeRate: MoneyValue.create(
                minor: BigInt(3357),
                currency: .crypto(.bitcoin)
            )
        )
        // WHEN: The amount is converted
        // THEN: An error should be thrown as the base currency of the exchange rate doesn't match the amount's currency.
        XCTAssertThrowsError(try amount.convert(using: exchangeRate))
    }
}
