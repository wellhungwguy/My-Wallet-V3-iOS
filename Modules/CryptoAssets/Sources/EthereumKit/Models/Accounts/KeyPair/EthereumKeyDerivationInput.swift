// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import PlatformKit

// Derivation Input for a HDWallet given a BIP39 mnemonic
// BIP39 Passphrase is currently not supported.
public struct EthereumKeyDerivationInput {

    public let mnemonic: String

    public init(mnemonic: String) {
        self.mnemonic = mnemonic
    }
}
