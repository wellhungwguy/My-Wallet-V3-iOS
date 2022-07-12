// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import Foundation

/// Upgrades the wallet to version 4
///
/// Going from version 3 to 4 we need the following steps
///  - Make the current xpriv/xpub as legacy
///  - Add a segwit (bech32) xpriv/xpub
///
final class Version4Workflow: WalletUpgradeWorkflow {

    static var supportedVersion: WalletPayloadVersion {
        .v4
    }

    func shouldPerformUpgrade(wrapper: Wrapper) -> Bool {
        !wrapper.isLatestVersion
    }

    func upgrade(wrapper: Wrapper) -> AnyPublisher<Wrapper, WalletUpgradeError> {
        getMasterNode(from: wrapper.wallet)
            .publisher
            .mapError { _ in WalletUpgradeError.unableToRetrieveSeedHex }
            .flatMap { masterNode -> AnyPublisher<HDWallet, WalletUpgradeError> in
                guard let hdWallet = wrapper.wallet.defaultHDWallet else {
                    return .failure(.upgradeFailed)
                }
                // run through the accounts of default HD Wallet
                let upgradedAccounts = hdWallet.accounts.map { account -> Account in
                    // for sanity let's recreate all derivations from master node for this account
                    let derivations = generateDerivations(
                        masterNode: masterNode,
                        index: account.index
                    )
                    return Account(
                        index: account.index,
                        label: account.label,
                        archived: account.archived,
                        defaultDerivation: .segwit,
                        derivations: derivations
                    )
                }
                let upgradedHDWallet = HDWallet(
                    seedHex: hdWallet.seedHex,
                    passphrase: hdWallet.passphrase,
                    mnemonicVerified: hdWallet.mnemonicVerified,
                    defaultAccountIndex: hdWallet.defaultAccountIndex,
                    accounts: upgradedAccounts
                )
                return .just(upgradedHDWallet)
            }
            .map { hdWallet in
                let wallet = NativeWallet(
                    guid: wrapper.wallet.guid,
                    sharedKey: wrapper.wallet.sharedKey,
                    doubleEncrypted: wrapper.wallet.doubleEncrypted,
                    doublePasswordHash: wrapper.wallet.doublePasswordHash,
                    metadataHDNode: wrapper.wallet.metadataHDNode,
                    txNotes: wrapper.wallet.txNotes,
                    tagNames: wrapper.wallet.tagNames,
                    options: wrapper.wallet.options,
                    hdWallets: [hdWallet],
                    addresses: wrapper.wallet.addresses
                )
                return Wrapper(
                    pbkdf2Iterations: Int(wrapper.pbkdf2Iterations),
                    version: Version4Workflow.supportedVersion.rawValue,
                    payloadChecksum: wrapper.payloadChecksum,
                    language: wrapper.language,
                    syncPubKeys: wrapper.syncPubKeys,
                    wallet: wallet
                )
            }
            .eraseToAnyPublisher()
    }
}
