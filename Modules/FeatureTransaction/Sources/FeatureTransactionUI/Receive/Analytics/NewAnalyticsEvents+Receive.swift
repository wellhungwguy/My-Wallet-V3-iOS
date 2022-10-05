// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import AnalyticsKit
import Foundation
import PlatformKit

extension AnalyticsEvents.New {
    public enum Receive: AnalyticsEvent {
        public var type: AnalyticsEventType { .nabu }

        case receiveDetailsCopied(accountType: AccountType, currency: String)
        case receiveDomainReverseResolved

        public enum AccountType: String, StringRawRepresentable {
            case savings = "SAVINGS"
            case trading = "TRADING"
            case userKey = "USERKEY"

            public init(_ account: BlockchainAccount?) {
                switch account {
                case is CryptoInterestAccount:
                    self = .savings
                case is CryptoTradingAccount:
                    self = .trading
                default:
                    self = .userKey
                }
            }
        }
    }
}
