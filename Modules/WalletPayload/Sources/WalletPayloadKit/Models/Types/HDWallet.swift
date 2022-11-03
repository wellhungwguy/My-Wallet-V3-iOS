// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation
import MetadataKit
import ToolKit
import WalletCore

public struct HDWallet: Equatable {
    public let seedHex: String
    public let passphrase: String
    public let mnemonicVerified: Bool
    public let defaultAccountIndex: Int
    public let accounts: [Account]

    var accountsNeedsReplenisment: Bool {
        accounts.isEmpty || accounts.any(\.needsReplenishment)
    }

    public init(
        seedHex: String,
        passphrase: String,
        mnemonicVerified: Bool,
        defaultAccountIndex: Int,
        accounts: [Account]
    ) {
        self.seedHex = seedHex
        self.passphrase = passphrase
        self.mnemonicVerified = mnemonicVerified
        self.defaultAccountIndex = defaultAccountIndex
        self.accounts = accounts
    }
}

// MARK: - HDWallet Creation

/// Creates a new `HDWallet` from the given mnemonic
/// - Parameters:
///   - mnemonic: A `String` representing a mnemonic phrase for this HDWallet
///   - accountName: A `String` representing the wallet's name
///   - totalAccounts: A `Int` for the total `Account`s to be created
///
/// Note: We create both legacy and segwit accounts
///
/// - Returns: Result<HDWallet, WalletCreateError>
func generateHDWallet(
    mnemonic: String,
    accountName: String,
    totalAccounts: Int = 1
) -> Result<HDWallet, WalletCreateError> {
    getHDWallet(from: mnemonic)
        .flatMap { hdWallet -> Result<(accounts: [Account], seedHex: String), WalletCreateError> in
            let seedHex = hdWallet.entropy.toHexString()
            let masterNode = hdWallet.seed.toHexString()
            let accounts = provideAccounts(count: totalAccounts, masterNode: masterNode, label: accountName)
            return .success((accounts, seedHex))
        }
        .map { accounts, seedHex in
            HDWallet(
                seedHex: seedHex,
                passphrase: "",
                mnemonicVerified: false,
                defaultAccountIndex: 0,
                accounts: accounts
            )
        }
}

/// Provides an array of `Account`s up to the given `count` and parameters
/// - Parameters:
///   - count: An `Int` for the total accounts to be created
///   - masterNode: A `String` to be used as a master node (BIP39 seed)
///   - label: A `String` to used as a prefix for each account
/// - Returns: An array of `Account`
private func provideAccounts(
    count: Int,
    masterNode: String,
    label: String
) -> [Account] {
    (0..<count).map { index in
        generateAccount(masterNode: masterNode, index: index, label: label)
    }
}

/// Creates an `Account` from the given parameters
/// - Parameters:
///   - masterNode: A `String` to be used as a master node (BIP39 seed)
///   - index: An `Int` to be used for the derivation
///   - label: A `String` to used as a prefix for each account
/// - Returns: A `Result<Account, WalletCreateError>`
private func generateAccount(
    masterNode: String,
    index: Int,
    label: String
) -> Account {
    let derivations = generateDerivations(masterNode: masterNode, index: index)
    let label = index > 0 ? "\(label)\(index + 1)" : label
    return createAccount(label: label, index: index, derivations: derivations)
}
