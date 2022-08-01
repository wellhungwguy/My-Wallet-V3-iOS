// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Errors
import FeatureCardPaymentDomain
import MoneyKit
import ToolKit

public enum Order {
    public enum Action: String, Codable {
        case buy = "BUY"
        case sell = "SELL"
    }
}

public enum OrderPayload {

    enum CreateActionType: String, Encodable {
        case confirm
        case pending
    }

    struct ConfirmOrder: Encodable {

        enum Callback {
            static var url: URL {
                Bundle.main.plist.BLOCKCHAIN_WALLET_PAGE_LINK[]
                    .flatMap(URL.https)
                    .or(default: "https://blockchainwallet.page.link")
                    .appendingPathComponent("obapproval")
            }
        }

        enum Partner {
            case card(redirectURL: String)
            case bank
            case funds
            case applePay(ApplePayToken)
        }

        struct Attributes: Encodable {
            struct EveryPay: Encodable {
                let customerUrl: String
            }

            let redirectURL: String?
            let everypay: EveryPay?
            let applePayPaymentToken: String?
            let callback: String?

            init(redirectURL: String?, callback: String?, applePay: ApplePayToken? = nil) {
                everypay = redirectURL.map(EveryPay.init)

                if let applePay = applePay,
                   let encoded = try? JSONEncoder().encode(applePay)
                {
                    applePayPaymentToken = String(data: encoded, encoding: .utf8)
                } else {
                    applePayPaymentToken = nil
                }

                self.redirectURL = redirectURL
                self.callback = callback
            }
        }

        let paymentMethodId: String?
        let action: CreateActionType
        let attributes: Attributes?

        init(partner: Partner, action: CreateActionType, paymentMethodId: String?) {
            switch partner {
            case .card(redirectURL: let url):
                attributes = Attributes(
                    redirectURL: url,
                    callback: nil
                )
            case .bank:
                attributes = Attributes(
                    redirectURL: nil,
                    callback: Callback.url.absoluteString
                )
            case .funds:
                attributes = nil
            case .applePay(let params):
                attributes = Attributes(
                    redirectURL: PartnerAuthorizationData.exitLink,
                    callback: nil,
                    applePay: params
                )
            }
            self.action = action
            self.paymentMethodId = paymentMethodId
        }
    }

    struct Request: Encodable {
        struct Input: Encodable {
            let symbol: String
            let amount: String
        }

        struct Output: Encodable {
            let symbol: String
        }

        let quoteId: String?
        let pair: String
        let action: Order.Action
        let input: Input
        let output: Output
        let paymentType: PaymentMethodPayloadType?
        let paymentMethodId: String?

        init(
            quoteId: String?,
            action: Order.Action,
            fiatValue: FiatValue,
            fiatCurrency: FiatCurrency,
            cryptoValue: CryptoValue,
            paymentType: PaymentMethod.MethodType? = nil,
            paymentMethodId: String? = nil
        ) {
            self.quoteId = quoteId
            self.action = action
            if paymentType?.isApplePay == true
                || paymentMethodId?.isEmpty == true
            {
                self.paymentMethodId = nil
            } else {
                self.paymentMethodId = paymentMethodId
            }
            self.paymentType = paymentType?.requestType
            switch action {
            case .buy:
                input = Input(
                    symbol: fiatValue.code,
                    amount: fiatValue.minorString
                )
                output = Output(symbol: cryptoValue.code)
                pair = "\(output.symbol)-\(input.symbol)"
            case .sell:
                input = Input(
                    symbol: cryptoValue.code,
                    amount: "\(cryptoValue.amount)"
                )
                output = Output(symbol: fiatCurrency.code)
                pair = "\(input.symbol)-\(output.symbol)"
            }
        }
    }

    public struct Response: Decodable {
        enum Side: String, Decodable {
            case buy = "BUY"
            case sell = "SELL"
        }

        public struct Attributes: Decodable {
            public enum PaymentState: String, Decodable {
                /// Should never happen. It means a case was forgotten by backend
                case initial = "INITIAL"

                /// We have to display a 3DS verification popup
                case waitingFor3DS = "WAITING_FOR_3DS_RESPONSE"

                /// 3DS valid
                case confirmed3DS = "CONFIRMED_3DS"

                /// Ready for capture, no need for 3DS
                case settled = "SETTLED"

                /// Payment voided
                case voided = "VOIDED"

                /// Payment abandonned
                case abandoned = "ABANDONED"

                /// Payment failed
                case failed = "FAILED"

                /// Just in case
                case unknown
            }

            public struct EveryPay: Decodable {
                public let paymentLink: String
                public let paymentState: PaymentState
            }

            public struct CardProvider: Decodable {
                public let cardAcquirerName: CardPayload.Acquirer?
                public let cardAcquirerAccountCode: String?
                public let paymentLink: String?
                public let paymentState: PaymentState
                public let clientSecret: String?
                public let publishableApiKey: String?
            }

            public let everypay: EveryPay?
            public let cardProvider: CardProvider?
            public let error: String?
        }

        let state: String

        let id: String

        let inputCurrency: String
        let inputQuantity: String

        let outputCurrency: String
        let outputQuantity: String

        let updatedAt: String
        let expiresAt: String

        let price: String?
        let fee: String?

        let paymentType: String
        let paymentError: String?

        public let paymentMethodId: String?
        let side: Side
        public let attributes: Attributes?
        @Optional.Codable public var ux: UX.Dialog?

        let processingErrorType: String?
    }
}

extension OrderPayload.Response.Attributes.EveryPay {

    private enum CodingKeys: String, CodingKey {
        case paymentLink
        case paymentState
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        paymentLink = try container.decode(String.self, forKey: .paymentLink)
        let paymentState = try container.decode(String.self, forKey: .paymentState)
        self.paymentState = OrderPayload.Response.Attributes.PaymentState(rawValue: paymentState) ?? .unknown
    }
}

extension OrderPayload.Response.Attributes.CardProvider {

    private enum CodingKeys: String, CodingKey {
        case cardAcquirerName
        case cardAcquirerAccountCode
        case paymentLink
        case paymentState
        case clientSecret
        case publishableApiKey
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        paymentLink = try container.decodeIfPresent(String.self, forKey: .paymentLink)
        let paymentState = try container.decode(String.self, forKey: .paymentState)
        self.paymentState = OrderPayload.Response.Attributes.PaymentState(rawValue: paymentState) ?? .unknown
        let acquirerName = try container.decodeIfPresent(String.self, forKey: .cardAcquirerName)
        cardAcquirerName = acquirerName.map(CardPayload.Acquirer.init(acquirer:))
        cardAcquirerAccountCode = try container.decodeIfPresent(String.self, forKey: .cardAcquirerAccountCode)
        clientSecret = try container.decodeIfPresent(String.self, forKey: .clientSecret)
        publishableApiKey = try container.decodeIfPresent(String.self, forKey: .publishableApiKey)
    }
}

extension OrderPayload.Response {
    public var authorizationState: PartnerAuthorizationData.State {
        if let everypay = attributes?.everypay {
            switch everypay.paymentState {
            case .waitingFor3DS:
                let url = URL(string: everypay.paymentLink)!
                return .required(.init(cardAcquirer: .everyPay, paymentLink: url))
            case .confirmed3DS, .settled:
                return .confirmed
            case .abandoned, .failed, .voided, .unknown, .initial:
                return .none
            }
        } else if let cardAcquirer = attributes?.cardProvider {
            switch cardAcquirer.paymentState {
            case .confirmed3DS, .settled:
                return .confirmed
            case .waitingFor3DS:
                switch cardAcquirer.cardAcquirerName {
                case .everyPay:
                    guard let paymentLink = cardAcquirer.paymentLink else {
                        return .none
                    }
                    return .required(.init(
                        cardAcquirer: .everyPay,
                        paymentLink: URL(string: paymentLink)
                    ))
                case .checkout:
                    guard let paymentLink = cardAcquirer.paymentLink else {
                        return .confirmed
                    }
                    return .required(.init(
                        cardAcquirer: .checkout,
                        paymentLink: URL(string: paymentLink),
                        publishableApiKey: cardAcquirer.publishableApiKey
                    ))
                case .stripe:
                    return .required(.init(
                        cardAcquirer: .stripe,
                        clientSecret: cardAcquirer.clientSecret,
                        publishableApiKey: cardAcquirer.publishableApiKey
                    ))
                case nil, .unknown:
                    return .none
                }
            case .abandoned, .failed, .voided, .unknown, .initial:
                return .none
            }
        }
        return .none
    }
}
