// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

public struct WalletKeyPair: Equatable {

    /// The wallet private key
    public let xpriv: String

    /// The wallet private key data
    public let privateKeyData: Data

    /// The wallet extended public key
    public let xpub: XPub
}
