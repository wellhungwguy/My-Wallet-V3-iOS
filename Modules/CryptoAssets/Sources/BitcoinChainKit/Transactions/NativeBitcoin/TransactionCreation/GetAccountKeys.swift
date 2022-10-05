// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import Errors
import MetadataHDWalletKit
import ToolKit
import WalletCore

struct BitcoinChainAccount: Identifiable {

    var id: String {
        "\(coin)-\(index)"
    }

    var index: Int32
    var coin: BitcoinChainCoin
}

public struct Mnemonic {
    let words: String

    public init(words: String) {
        self.words = words
    }
}

struct AccountKeyContext {

    fileprivate typealias GetKey = (String) -> WalletCore.PrivateKey

    fileprivate typealias GetXPriv = (WalletCore.Purpose) -> String

    fileprivate typealias GetXPub = (WalletCore.Purpose) -> String

    struct Derivation {

        private enum Chains {
            static let receive: UInt32 = 0
            static let change: UInt32 = 1
        }

        var xpriv: String {
            getXPriv(type.walletCorePurpose)
        }

        var xpub: String {
            getXPub(type.walletCorePurpose)
        }

        private var purpose: UInt32 {
            type.purpose
        }

        let type: BitcoinChainKit.DerivationType
        let coin: UInt32
        let accountIndex: UInt32

        private let getKey: GetKey
        private let getXPriv: GetXPriv
        private let getXPub: GetXPub

        fileprivate init(
            type: BitcoinChainKit.DerivationType,
            coin: UInt32,
            accountIndex: UInt32,
            getKey: @escaping GetKey,
            getXPriv: @escaping GetXPriv,
            getXPub: @escaping GetXPub
        ) {
            self.type = type
            self.coin = coin
            self.accountIndex = accountIndex
            self.getKey = getKey
            self.getXPriv = getXPriv
            self.getXPub = getXPub
        }

        func accountPrivateKey() -> WalletCore.PrivateKey {
            let purpose = type.purpose
            let path = "m/\(purpose)'/\(coin)'/\(accountIndex)'/"
            return getKey(path)
        }

        func receivePrivateKey(
            receiveIndex: UInt32
        ) -> WalletCore.PrivateKey {
            let purpose = type.purpose
            let path = "m/\(purpose)'/\(coin)'/\(accountIndex)'/\(Chains.receive)/\(receiveIndex)/"
            return getKey(path)
        }

        func changePrivateKey(
            changeIndex: UInt32
        ) -> WalletCore.PrivateKey {
            let purpose = type.purpose
            let path = "m/\(purpose)'/\(coin)'/\(accountIndex)'/\(Chains.change)/\(changeIndex)/"
            return getKey(path)
        }

        func childKey(
            with childPath: [WalletCore.DerivationPath.Index]
        ) -> WalletCore.PrivateKey {
            let purpose = type.purpose

            let accountPath: [WalletCore.DerivationPath.Index] = [
                .init(purpose, hardened: true),
                .init(coin, hardened: true),
                .init(accountIndex, hardened: true)
            ]

            let pathComponents = accountPath + childPath

            let path = pathComponents.reduce(into: "m/") { path, component in
                path += "\(component.description)/"
            }

            return getKey(path)
        }
    }

    struct Derivations {

        var all: [Derivation] {
            [legacy, segWit]
        }

        let segWit: Derivation
        let legacy: Derivation

        private init(segWit: Derivation, legacy: Derivation) {
            self.segWit = segWit
            self.legacy = legacy
        }

        // swiftlint:disable function_parameter_count
        fileprivate static func create(
            wallet: WalletCore.HDWallet,
            coin: UInt32,
            accountIndex: UInt32,
            getKey: @escaping GetKey,
            getXPriv: @escaping GetXPriv,
            getXPub: @escaping GetXPub
        ) -> Self {
            Self(
                segWit: Derivation(
                    type: .bech32,
                    coin: coin,
                    accountIndex: accountIndex,
                    getKey: getKey,
                    getXPriv: getXPriv,
                    getXPub: getXPub
                ),
                legacy: Derivation(
                    type: .legacy,
                    coin: coin,
                    accountIndex: accountIndex,
                    getKey: getKey,
                    getXPriv: getXPriv,
                    getXPub: getXPub
                )
            )
        }
    }

    var xpubs: [XPub] {
        derivations.all
            .map { derivation in
                XPub(
                    address: derivation.xpub,
                    derivationType: derivation.type
                )
            }
    }

    func defaultDerivation(coin: BitcoinChainCoin) -> Derivation {
        switch coin {
        case .bitcoin:
            return derivations.segWit
        case .bitcoinCash:
            return derivations.legacy
        }
    }

    let wallet: WalletCore.HDWallet
    let coin: UInt32
    let accountIndex: UInt32
    let derivations: Derivations

    fileprivate init(
        wallet: WalletCore.HDWallet,
        coin: UInt32,
        accountIndex: UInt32
    ) {
        self.wallet = wallet
        self.coin = coin
        self.accountIndex = accountIndex
        derivations = .create(
            wallet: wallet,
            coin: coin,
            accountIndex: accountIndex,
            getKey: Self.getKey(wallet: wallet, coin: coin),
            getXPriv: Self.getXPriv(wallet: wallet, coin: coin, accountIndex: accountIndex),
            getXPub: Self.getXPub(wallet: wallet, coin: coin, accountIndex: accountIndex)
        )
    }

    private static func getKey(
        wallet: WalletCore.HDWallet,
        coin: UInt32
    ) -> GetKey {
        { derivationPath in
            wallet.getKey(
                coin: CoinType(rawValue: coin)!,
                derivationPath: derivationPath
            )
        }
    }

    private static func getXPriv(
        wallet: WalletCore.HDWallet,
        coin: UInt32,
        accountIndex: UInt32
    ) -> GetXPriv {
        { purpose in
            getHDWalletPK(
                wallet: wallet,
                coin: coin,
                purpose: purpose.rawValue,
                accountIndex: accountIndex
            ).extended()
        }
    }

    private static func getXPub(
        wallet: WalletCore.HDWallet,
        coin: UInt32,
        accountIndex: UInt32
    ) -> GetXPub {
        { purpose in
            getHDWalletPK(
                wallet: wallet,
                coin: coin,
                purpose: purpose.rawValue,
                accountIndex: accountIndex
            ).extendedPublic()
        }
    }

    private static func getHDWalletPK(
        wallet: WalletCore.HDWallet,
        coin: UInt32,
        purpose: UInt32,
        accountIndex: UInt32
    ) -> MetadataHDWalletKit.PrivateKey {
        let masterKey = MetadataHDWalletKit.PrivateKey(seed: wallet.seed, coin: .bitcoin)
        return masterKey
            .derived(at: .hardened(purpose))
            .derived(at: .hardened(coin))
            .derived(at: .hardened(accountIndex))
    }
}

extension DerivationType {

    var walletCorePurpose: WalletCore.Purpose {
        switch self {
        case .legacy:
            return .bip44
        case .bech32:
            return .bip84
        }
    }
}

public typealias WalletMnemonicProvider = () -> AnyPublisher<Mnemonic, Error>

func getAccountKeys(
    for account: BitcoinChainAccount,
    walletMnemonicProvider: WalletMnemonicProvider
) -> AnyPublisher<AccountKeyContext, Error> {
    walletMnemonicProvider()
        .map { mnemonic in
            getAccountKeyContext(for: account, mnemonic: mnemonic)
        }
        .eraseToAnyPublisher()
}

func getAccountKeyContext(
    for account: BitcoinChainAccount,
    mnemonic: Mnemonic
) -> AccountKeyContext {
    guard let wallet = WalletCore.HDWallet(mnemonic: mnemonic.words, passphrase: "") else {
        fatalError("Invalid Mnemonic")
    }
    return AccountKeyContext(
        wallet: wallet,
        coin: account.coin.derivationCoinType,
        accountIndex: UInt32(account.index)
    )
}
