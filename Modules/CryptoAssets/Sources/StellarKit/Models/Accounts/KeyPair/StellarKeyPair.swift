// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import PlatformKit

struct StellarKeyPair {
    var secret: String {
        privateKey.secret
    }

    let accountID: String
    let privateKey: StellarPrivateKey

    init(accountID: String, secret: String) {
        self.accountID = accountID
        privateKey = StellarPrivateKey(secret: secret)
    }
}
