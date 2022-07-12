// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import Foundation
import Localization

/// Upgrades the wallet to version 3
///
/// Going from version 2 to 3 we need the following steps
///  - generate a mnemonic
///  - create an hd wallet
///     - add a legacy xpriv/xpub
///
/// - Note: At the time of writing this we already support `v4`.
/// This means that we don't create the correct json format for `v3`, since we do not support it anymore.
/// Instead we use this workflow to generate the mnemonic, provide the seed hex and create the legacy derivation,
/// which we'll use to easily upgrade to `v4`.
/// For context the `Account` model on `v3` did not had the `derivations` object.
///
final class Version3Workflow: WalletUpgradeWorkflow {
    private let entropyService: RNGServiceAPI
    private let operationQueue: DispatchQueue

    init(
        entropyService: RNGServiceAPI,
        operationQueue: DispatchQueue
    ) {
        self.entropyService = entropyService
        self.operationQueue = operationQueue
    }

    static var supportedVersion: WalletPayloadVersion {
        .v3
    }

    func shouldPerformUpgrade(wrapper: Wrapper) -> Bool {
        !wrapper.wallet.isHDWallet
    }

    func upgrade(wrapper: Wrapper) -> AnyPublisher<Wrapper, WalletUpgradeError> {
        provideMnemonic(
            strength: .normal,
            queue: operationQueue,
            entropyProvider: entropyService.generateEntropy(count:)
        )
        .mapError(WalletUpgradeError.mnemonicFailure)
        .receive(on: operationQueue)
        .flatMap { [provideAccount] mnemonic -> AnyPublisher<HDWallet, WalletUpgradeError> in
            getHDWallet(from: mnemonic)
                .flatMap { hdWallet -> Result<(account: Account, seedHex: String), WalletCreateError> in
                    let seedHex = hdWallet.entropy.toHexString()
                    let masterNode = hdWallet.seed.toHexString()
                    let account = provideAccount(masterNode)
                    return .success((account, seedHex))
                }
                .map { account, seedHex in
                    HDWallet(
                        seedHex: seedHex,
                        passphrase: "",
                        mnemonicVerified: false,
                        defaultAccountIndex: 0,
                        accounts: [account]
                    )
                }
                .mapError(WalletUpgradeError.walletCreateError)
                .publisher
                .eraseToAnyPublisher()
        }
        .map { hdWallet -> Wrapper in
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
                version: Version3Workflow.supportedVersion.rawValue,
                payloadChecksum: wrapper.payloadChecksum,
                language: wrapper.language,
                syncPubKeys: wrapper.syncPubKeys,
                wallet: wallet
            )
        }
        .eraseToAnyPublisher()
    }

    // As part of v3 upgrade we create a legacy derivation and assign it to a new Account
    // again, we don't adhere to the version 3 json format.
    private func provideAccount(masterNode: String) -> Account {
        let legacyDerivation = generateDerivation(
            type: .legacy,
            index: 0,
            masterNode: masterNode
        )
        return createAccount(
            label: LocalizationConstants.Account.myWallet,
            index: 0,
            derivations: [legacyDerivation]
        )
    }
}
