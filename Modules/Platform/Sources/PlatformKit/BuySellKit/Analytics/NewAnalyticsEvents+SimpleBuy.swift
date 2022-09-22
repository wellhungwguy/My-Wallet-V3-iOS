// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import AnalyticsKit
import Foundation

extension AnalyticsEvents.New {
    public enum SimpleBuy: AnalyticsEvent {

        public var type: AnalyticsEventType { .nabu }

        case buyPaymentMethodSelected(paymentType: PaymentType)
        case linkBankClicked(origin: LinkBank.Origin)

        public enum PaymentType: String, StringRawRepresentable {
            case bankAccount = "BANK_ACCOUNT"
            case bankTransfer = "BANK_TRANSFER"
            case funds = "FUNDS"
            case paymentCard = "PAYMENT_CARD"
            case applePay = "APPLE_PAY"

            public init(paymentMethod: PaymentMethod) {
                switch paymentMethod.type {
                case .card:
                    self = .paymentCard
                case .bankAccount:
                    self = .bankAccount
                case .bankTransfer:
                    self = .bankTransfer
                case .funds:
                    self = .funds
                case .applePay:
                    self = .applePay
                }
            }
        }

        public enum LinkBank {
            public enum Origin: String, StringRawRepresentable {
                case buy = "BUY"
            }
        }
    }
}
