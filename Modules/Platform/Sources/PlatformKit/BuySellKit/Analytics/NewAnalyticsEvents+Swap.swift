// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import AnalyticsKit
import Foundation

extension AnalyticsEvents.New {
    public enum Swap: AnalyticsEvent {

        public var type: AnalyticsEventType { .nabu }

        case swapRequested(
            exchangeRate: Double,
            inputAmount: Double,
            inputCurrency: String,
            inputType: AccountType,
            networkFeeInputAmount: Double,
            networkFeeInputCurrency: String,
            networkFeeOutputAmount: Double,
            networkFeeOutputCurrency: String,
            outputAmount: Double,
            outputCurrency: String,
            outputType: AccountType
        )
    }

    public enum Origin: String, StringRawRepresentable {
        case dashboardPromo = "DASHBOARD_PROMO"
        case navigation = "NAVIGATION"
        case currencyPage = "CURRENCY_PAGE"
    }

    public enum AccountType: String, StringRawRepresentable {
        case trading = "TRADING"
        case userKey = "USERKEY"

        public init(_ account: BlockchainAccount) {
            switch account {
            case is CryptoNonCustodialAccount:
                self = .userKey
            default:
                self = .trading
            }
        }
    }
}
