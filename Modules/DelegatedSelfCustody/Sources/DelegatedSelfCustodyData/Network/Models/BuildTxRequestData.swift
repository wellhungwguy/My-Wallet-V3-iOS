// Copyright © Blockchain Luxembourg S.A. All rights reserved.

struct BuildTxRequestData {
    let currency: String
    let account: Int
    let type: String
    let destination: String
    let amount: String
    let fee: String
    let maxVerificationVersion: Int?
}
