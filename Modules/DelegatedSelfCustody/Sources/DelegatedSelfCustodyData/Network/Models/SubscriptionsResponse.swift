// Copyright © Blockchain Luxembourg S.A. All rights reserved.

struct SubscriptionsResponse: Decodable {
    struct Entry: Decodable {
        let ticker: String
        let account: Int
        let accountName: String?
        let balance: Int?
        let unconfirmed: Int?
        let price: Int?
    }

    let currencies: [Entry]
}
