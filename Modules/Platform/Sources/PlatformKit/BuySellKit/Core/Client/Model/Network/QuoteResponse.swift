// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BigInt
import Errors
import MoneyKit
import ToolKit

struct QuoteResponse: Decodable {
    struct FeeDetails: Decodable {
        enum FeeFlag: String, Decodable {
            case newUserWaiver = "NEW_USER_WAIVER"
        }

        let feeWithoutPromo: String
        let fee: String
        let feeFlags: [FeeFlag]
    }

    let quoteId: String
    let quoteMarginPercent: Double
    let quoteCreatedAt: String
    let quoteExpiresAt: String

    /// The price is in destination currency specified by the `brokerage/quote` request
    let price: String

    let networkFee: String?
    let staticFee: String?
    let feeDetails: FeeDetails
    let settlementDetails: SettlementDetails
    let sampleDepositAddress: String?
}

public struct SettlementDetails: Decodable {
    public enum AvailabilityType: String, Decodable {
        case instant = "INSTANT"
        case regular = "REGULAR"
        case unavailable = "UNAVAILABLE"
    }

    public enum ReasonType: String, Decodable {
        case requiresUpdate = "REQUIRES_UPDATE"
        case insufficientBalance = "INSUFFICIENT_BALANCE"
        case staleBalance = "STALE_BALANCE"
        case generic = "GENERIC"
    }

    public let availability: AvailabilityType
    public let reason: ReasonType?
    public let ux: UX.Dialog?
}

public struct Quote {

    // MARK: - Types

    enum SetupError: Error {
        case dateFormatting
        case feeParsing
        case priceParsing
        case wrongCurrenciesPair
    }

    // MARK: - Properties

    public let quoteId: String?
    public let quoteCreatedAt: Date
    public let quoteExpiresAt: Date
    public let fee: MoneyValue
    public let rate: MoneyValue
    public let estimatedDestinationAmount: MoneyValue
    public let estimatedSourceAmount: MoneyValue
    public let settlementDetails: SettlementDetails

    private let dateFormatter = DateFormatter.sessionDateFormat

    // MARK: - Setup

    init(
        sourceCurrency: Currency,
        destinationCurrency: Currency,
        value: MoneyValue,
        response: QuoteResponse
    ) throws {
        self.quoteId = response.quoteId
        self.settlementDetails = response.settlementDetails

        // formatting dates
        guard let quoteCreatedDate = dateFormatter.date(from: response.quoteCreatedAt),
              let quoteExpiresDate = dateFormatter.date(from: response.quoteExpiresAt)
        else {
            throw SetupError.dateFormatting
        }
        self.quoteCreatedAt = quoteCreatedDate
        self.quoteExpiresAt = quoteExpiresDate

        // parsing fee (source currency)
        guard let feeMinor = Decimal(string: response.feeDetails.fee) else {
            throw SetupError.feeParsing
        }
        // parsing price (destination currency)
        guard let priceMinorBigInt = BigInt(response.price) else {
            throw SetupError.priceParsing
        }

        switch (sourceCurrency, destinationCurrency) {
        // buy flow
        case (let source as FiatCurrency, let destination as CryptoCurrency):
            guard let fiatAmount = value.fiatValue else {
                fatalError("Amount must be in fiat for a buy quote")
            }
            let estimatedFiatAmount = FiatValue.create(minor: fiatAmount.minorAmount, currency: source)
            let cryptoPriceValue = CryptoValue.create(minor: priceMinorBigInt, currency: destination)
            let cryptoPriceDisplayString = cryptoPriceValue.toDisplayString(includeSymbol: false, locale: Locale.US)
            guard let cryptoMajorAmount = Decimal(string: cryptoPriceDisplayString) else {
                throw SetupError.priceParsing
            }
            let fiatRate = FiatValue.create(major: 1 / cryptoMajorAmount, currency: source)
            let estimatedCryptoAmount = CryptoValue.create(
                major: estimatedFiatAmount.minorAmount.decimalDivision(by: fiatRate.minorAmount),
                currency: destination
            )
            self.estimatedSourceAmount = estimatedFiatAmount.moneyValue
            self.estimatedDestinationAmount = estimatedCryptoAmount.moneyValue
            self.rate = fiatRate.moneyValue
            self.fee = MoneyValue.create(minor: feeMinor, currency: .fiat(source))

        // sell flow
        case (let source as CryptoCurrency, let destination as FiatCurrency):
            guard let cryptoAmount = value.cryptoValue else {
                fatalError("Amount must be in crypto for a sell quote")
            }
            let estimatedCryptoAmount = CryptoValue.create(minor: cryptoAmount.minorAmount, currency: source)
            let fiatPriceValue = FiatValue.create(minor: priceMinorBigInt, currency: destination)
            guard let fiatMajorAmount = Decimal(string: fiatPriceValue.displayString) else {
                throw SetupError.priceParsing
            }
            let cryptoRate = CryptoValue.create(major: 1 / fiatMajorAmount, currency: source)
            let estimatedFiatAmount = FiatValue.create(
                major: estimatedCryptoAmount.minorAmount.decimalDivision(by: cryptoRate.minorAmount),
                currency: destination
            )
            self.estimatedSourceAmount = estimatedCryptoAmount.moneyValue
            self.estimatedDestinationAmount = estimatedFiatAmount.moneyValue
            self.rate = cryptoRate.moneyValue
            self.fee = MoneyValue.create(minor: feeMinor, currency: .crypto(source))

        // swap flow
        case (let source as CryptoCurrency, let destination as CryptoCurrency):
            guard let cryptoAmount = value.cryptoValue else {
                fatalError("Amount must be in crypto for a sell quote")
            }
            let fromTokenAmount = CryptoValue.create(minor: cryptoAmount.minorAmount, currency: source)
            let toTokenPriceValue = CryptoValue.create(minor: priceMinorBigInt, currency: destination)
            guard let toTokenMajorAmount = Decimal(string: toTokenPriceValue.displayString) else {
                throw SetupError.priceParsing
            }
            let fromTokenRate = CryptoValue.create(major: 1 / toTokenMajorAmount, currency: source)
            let toTokenAmount = CryptoValue.create(
                major: fromTokenAmount.minorAmount.decimalDivision(by: fromTokenRate.minorAmount),
                currency: destination
            )
            self.estimatedSourceAmount = fromTokenAmount.moneyValue
            self.estimatedDestinationAmount = toTokenAmount.moneyValue
            self.rate = fromTokenRate.moneyValue
            self.fee = MoneyValue.create(minor: feeMinor, currency: .crypto(source))

        default:
            fatalError("Unsupported source and destination currency pair")
        }
    }
}
