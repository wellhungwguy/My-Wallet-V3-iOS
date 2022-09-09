// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import ToolKit

struct PushTxRequestData {
    struct Signature {
        let preImage: String
        let signingKey: String
        let signatureAlgorithm: SignatureAlgorithmResponse
        let signature: String
    }

    let currency: String
    let rawTx: JSONValue
    let signatures: [Signature]
}
