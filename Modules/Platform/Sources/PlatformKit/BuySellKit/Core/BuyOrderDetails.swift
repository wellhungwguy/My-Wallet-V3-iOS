// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import AnalyticsKit
import Errors
import FeatureCardPaymentDomain
import MoneyKit

public struct BuyOrderDetails: Equatable {

    public typealias State = OrderDetailsState

    public let fiatValue: FiatValue
    public let cryptoValue: CryptoValue

    public var price: FiatValue?
    public var fee: FiatValue?

    public let identifier: String

    public let paymentMethod: PaymentMethod.MethodType

    public let creationDate: Date?
    public let error: String?
    public let ux: Nabu.Error.UX?

    public internal(set) var paymentMethodId: String?

    public let authorizationData: PartnerAuthorizationData?
    public let state: State
    public let paymentProcessorErrorType: PaymentProcessorErrorType?

    // MARK: - Setup

    // swiftlint:disable cyclomatic_complexity
    init?(recorder: AnalyticsEventRecorderAPI, response: OrderPayload.Response) {
        guard let state = State(rawValue: response.state) else {
            return nil
        }
        guard let fiatCurrency = FiatCurrency(code: response.inputCurrency) else {
            return nil
        }
        guard let cryptoCurrency = CryptoCurrency(code: response.outputCurrency) else {
            return nil
        }

        guard let cryptoValue = CryptoValue.create(minor: response.outputQuantity, currency: cryptoCurrency) else {
            return nil
        }
        guard let fiatValue = FiatValue.create(minor: response.inputQuantity, currency: fiatCurrency) else {
            return nil
        }

        guard let paymentType = PaymentMethodPayloadType(rawValue: response.paymentType) else {
            return nil
        }

        identifier = response.id

        if let processingErrorType = response.processingErrorType {
            switch processingErrorType {
            case "ISSUER":
                paymentProcessorErrorType = .issuer
            default:
                paymentProcessorErrorType = .unknown
            }
        } else {
            paymentProcessorErrorType = nil
        }

        self.fiatValue = fiatValue
        self.cryptoValue = cryptoValue
        self.state = state
        paymentMethod = PaymentMethod.MethodType(type: paymentType, currency: .fiat(fiatCurrency))
        paymentMethodId = response.paymentMethodId
        authorizationData = PartnerAuthorizationData(orderPayloadResponse: response)

        if let price = response.price {
            self.price = FiatValue.create(minor: price, currency: fiatCurrency)
        }

        if let fee = response.fee {
            self.fee = FiatValue.create(minor: fee, currency: fiatCurrency)
        }

        creationDate = DateFormatter.utcSessionDateFormat.date(from: response.updatedAt)
        if creationDate == nil {
            recorder.record(event: AnalyticsEvents.DebugEvent.updatedAtParsingError(date: response.updatedAt))
        }

        error = response.paymentError ?? response.attributes?.error
        ux = response.ux
    }
}

extension OrderPayload.Response: OrderPayloadResponseAPI {}
