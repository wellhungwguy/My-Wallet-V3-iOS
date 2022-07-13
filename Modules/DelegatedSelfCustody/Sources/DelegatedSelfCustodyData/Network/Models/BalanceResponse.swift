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
        let amount: CurrencyAmount
        let price: Decimal?
        let ticker: String
        let unconfirmed: CurrencyAmount
    }

    struct SubscriptionEntry: Decodable {
        let ticker: String
        let accounts: Int
        let pubkeyCount: Int
    }

    let currencies: [BalanceEntry]
    let subscriptions: [SubscriptionEntry]
}
