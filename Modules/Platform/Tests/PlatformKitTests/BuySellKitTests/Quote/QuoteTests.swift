// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BigInt
import MoneyKit
@testable import PlatformKit
import XCTest

final class SimpleBuyQuoteTests: XCTestCase {

    func testAllRegions() throws {
        let sut = try createTestCases(locales: [.US, .Canada, .GreatBritain, .France, .Japan, .Lithuania])
        for this in sut {
            XCTAssertNotNil(this.quote)
            XCTAssertFalse(this.quote.estimatedDestinationAmount.isZero, "\(this.locale) has zero estimatedAmount")
            XCTAssertEqual(this.quote.fee.displayMajorValue, 12.5, "\(this.locale) fee major value should be 12.5")
        }
    }
}

extension SimpleBuyQuoteTests {

    private struct QuoteTestCase {
        let locale: Locale
        let response: QuoteResponse
        let quote: Quote!
    }

    private func createTestCases(locales: [Locale]) throws -> [QuoteTestCase] {
        try locales.map { try createTestCase(locale: $0) }
    }

    private func createTestCase(locale: Locale) throws -> QuoteTestCase {
        let response = QuoteResponse(
            quoteId: "00000000-0000-0000-0000-000000000000",
            quoteMarginPercent: 0.5,
            quoteCreatedAt: "2021-12-31T01:00:02.030000000Z",
            quoteExpiresAt: "2021-12-31T01:00:04.030000000Z",
            price: "2300",
            networkFee: nil,
            staticFee: nil,
            feeDetails: .init(
                feeWithoutPromo: "1250",
                fee: "1250",
                feeFlags: []
            ),
            settlementDetails: .init(
                availability: .instant,
                reason: nil,
                ux: nil
            ),
            sampleDepositAddress: nil
        )
        let twoThousandFiveHundred = FiatValue.create(minor: "250000", currency: .GBP)!
        let quote = try Quote(
            sourceCurrency: FiatCurrency.GBP,
            destinationCurrency: CryptoCurrency.bitcoin,
            value: MoneyValue(fiatValue: twoThousandFiveHundred),
            response: response
        )
        return QuoteTestCase(locale: locale, response: response, quote: quote)
    }
}
