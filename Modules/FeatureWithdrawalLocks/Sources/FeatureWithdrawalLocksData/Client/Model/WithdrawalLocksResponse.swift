// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

struct WithdrawalLocksResponse: Decodable {

    struct Lock: Decodable {
        let expiresAt: String
        let amount: Amount
        let bought: Amount?
    }

    struct Amount: Decodable {
        let amount: String
        let currency: String
    }

    let locks: [Lock]
    let totalLocked: Amount
}
