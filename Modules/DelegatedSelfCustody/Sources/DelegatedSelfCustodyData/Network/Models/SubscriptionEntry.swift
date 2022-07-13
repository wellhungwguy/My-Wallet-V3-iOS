// Copyright © Blockchain Luxembourg S.A. All rights reserved.

struct SubscriptionEntry: Encodable, Equatable {
    struct Account: Encodable, Equatable {
        let index: Int
        let name: String
    }

    struct PubKey: Encodable, Equatable {
        let pubkey: String
        let style: String
        let descriptor: Int
    }

    let currency: String
    let account: Account
    let pubkeys: [PubKey]
}
