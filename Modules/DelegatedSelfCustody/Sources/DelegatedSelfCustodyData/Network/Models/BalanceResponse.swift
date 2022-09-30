// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

struct BalanceResponse: Decodable {
    struct BalanceEntry: Decodable {
        struct Account: Decodable {
            let index: Int
            let name: String
        }

        struct CurrencyAmount: Decodable {
            let amount: String
            let precision: Int
        }

        let account: Account
        let amount: CurrencyAmount?
        let price: Decimal?
        let ticker: String
    }

    struct SubscriptionEntry: Decodable {
        let ticker: String
        let accounts: Int
        let pubKeyCount: Int
    }

    let currencies: [BalanceEntry]
    let subscriptions: [SubscriptionEntry]
}
