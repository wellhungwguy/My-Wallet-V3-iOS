// Copyright © Blockchain Luxembourg S.A. All rights reserved.

struct PushTxRequestData {
    struct Signature {
        let preImage: String
        let signingKey: String
        let signatureAlgorithm: String
        let signature: String
    }

    let currency: String
    let signatures: [Signature]
}
