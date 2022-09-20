// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import PlatformKit

public struct EthereumKeyPair: Equatable {
    public let accountID: String
    public let privateKey: EthereumPrivateKey

    public init(accountID: String, privateKey: EthereumPrivateKey) {
        self.accountID = accountID
        self.privateKey = privateKey
    }
}
