// Copyright © Blockchain Luxembourg S.A. All rights reserved.

struct BuildTxResponse: Decodable {
    struct Summary: Decodable {
        let relativeFee: String
        let absoluteFeeMaximum: String
        let absoluteFeeMinimum: String
        let amount: String
        let balance: String
    }

    struct PreImage: Decodable {
        let preImage: String
        let signingKey: String
        let descriptor: String
        let signatureAlgorithm: String
    }

    let summary: Summary
    let preImages: [PreImage]
}
