// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import Errors
import HDWalletKit
import MoneyKit
import ToolKit
import WalletCore
import WalletPayloadKit

func getWalletKeyPairs(
    unspentOutputs: [UnspentOutput],
    accountKeyContext: AccountKeyContext
) -> [WalletKeyPair] {
    unspentOutputs
        .compactMap { utxo -> (UnspentOutput, WalletCoreKeyPair)? in
            let walletCoreKeyPair = try? walletCoreKeyPair(
                for: utxo,
                context: accountKeyContext
            ).get()
            guard let keyPair = walletCoreKeyPair else {
                return nil
            }
            return (utxo, keyPair)
        }
        .map { utxo, walletCoreKeyPair -> WalletKeyPair in
            WalletKeyPair(
                xpriv: walletCoreKeyPair.xpriv,
                privateKeyData: walletCoreKeyPair.privateKeyData,
                xpub: XPub(
                    address: walletCoreKeyPair.xpub,
                    derivationType: utxo.isSegwit ? .bech32 : .legacy
                )
            )
        }
}

public struct WalletCoreKeyPair {

    public var privateKeyData: Data {
        privateKey.data
    }

    public let privateKey: WalletCore.PrivateKey
    public let xpriv: String
    public let xpub: String

    public init(
        privateKey: PrivateKey,
        xpriv: String,
        xpub: String
    ) {
        self.privateKey = privateKey
        self.xpriv = xpriv
        self.xpub = xpub
    }
}

private func walletCoreKeyPair(
    for unspentOutput: UnspentOutput,
    context: AccountKeyContext
) -> Result<WalletCoreKeyPair, Error> {
    derivationPath(for: unspentOutput)
        .map(\.walletCoreComponents)
        .map { childKeyPath -> WalletCoreKeyPair in
            let unspentOutputIsSegWit = unspentOutput.isSegwit
            let derivation = context.derivations.all
                .first(where: { derivation in
                    derivation.type.isSegwit == unspentOutputIsSegWit
                })!
            let key = derivation.childKey(with: childKeyPath)
            let xpriv = derivation.xpriv
            let xpub = derivation.xpub
            return WalletCoreKeyPair(
                privateKey: key,
                xpriv: xpriv,
                xpub: xpub
            )
        }
}

func derivationPath(
    for unspentOutput: UnspentOutput
) -> Result<HDWalletKit.HDKeyPath, Error> {
    HDKeyPath.from(string: unspentOutput.xpub.path)
        .eraseError()
}

extension DerivationComponent {

    fileprivate var walletCoreDerivationComponent: WalletCore.DerivationPath.Index {
        switch self {
        case .normal(let index):
            return .init(index, hardened: false)
        case .hardened(let index):
            return .init(index, hardened: true)
        }
    }
}

extension HDKeyPath {

    fileprivate var walletCoreComponents: [WalletCore.DerivationPath.Index] {
        components.map(\.walletCoreDerivationComponent)
    }
}
