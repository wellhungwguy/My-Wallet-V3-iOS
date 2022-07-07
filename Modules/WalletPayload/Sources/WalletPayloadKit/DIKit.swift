// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit
import Foundation
import MetadataKit

enum WalletRepoOperationsQueue {
    static let queueTag = "op.queue.tag"
}

extension DependencyContainer {

    // MARK: - WalletPayloadKit Module

    // swiftlint:disable closure_body_length
    public static var walletPayloadKit = module {

        single(tag: WalletRepoOperationsQueue.queueTag) { () -> DispatchQueue in
            DispatchQueue(label: "wallet.payload.operations.queue")
        }

        factory { () -> ForgetWalletAPI in
            ForgetWallet(
                walletRepo: DIKit.resolve(),
                walletState: DIKit.resolve()
            )
        }

        single { () -> WalletSyncAPI in
            let targetQueue: DispatchQueue = DIKit.resolve(tag: WalletRepoOperationsQueue.queueTag)
            let queue = DispatchQueue(label: "wallet.sync.op.queue", qos: .userInitiated, target: targetQueue)
            return WalletSync(
                walletHolder: DIKit.resolve(),
                walletRepo: DIKit.resolve(),
                payloadCrypto: PayloadCrypto(cryptor: AESCryptor()),
                walletEncoder: DIKit.resolve(),
                saveWalletRepository: DIKit.resolve(),
                operationQueue: queue,
                checksumProvider: checksumHex(data:)
            )
        }

        factory { () -> WalletFetcherAPI in
            let targetQueue: DispatchQueue = DIKit.resolve(tag: WalletRepoOperationsQueue.queueTag)
            let queue = DispatchQueue(label: "wallet.fetching.op.queue", qos: .userInitiated, target: targetQueue)
            return WalletFetcher(
                walletRepo: DIKit.resolve(),
                payloadCrypto: DIKit.resolve(),
                walletLogic: DIKit.resolve(),
                walletPayloadRepository: DIKit.resolve(),
                operationsQueue: queue
            )
        }

        factory { () -> WalletUpgraderAPI in
            let targetQueue: DispatchQueue = DIKit.resolve(tag: WalletRepoOperationsQueue.queueTag)
            let queue = DispatchQueue(label: "wallet.upgrading.op.queue", qos: .userInitiated, target: targetQueue)
            let version3Flow = Version3Workflow(
                entropyService: DIKit.resolve(),
                operationQueue: queue
            )
            let version4Flow = Version4Workflow()
            return WalletUpgrader(
                workflows: [version3Flow, version4Flow]
            )
        }

        factory { () -> WalletLogic in
            let walletCreator: WalletDecoderAPI = DIKit.resolve()
            let decoder = walletCreator.createWallet
            let upgrader: WalletUpgraderAPI = DIKit.resolve()
            return WalletLogic(
                holder: DIKit.resolve(),
                decoder: decoder,
                upgrader: upgrader,
                metadata: DIKit.resolve(),
                walletSync: DIKit.resolve(),
                notificationCenter: .default
            )
        }

        factory { () -> WalletRecoveryServiceAPI in
            let walletLogic: WalletLogic = DIKit.resolve()
            let payloadCrypto: PayloadCryptoAPI = DIKit.resolve()
            let repo: WalletRepoAPI = DIKit.resolve()
            let payloadRepository: WalletPayloadRepositoryAPI = DIKit.resolve()
            let targetQueue: DispatchQueue = DIKit.resolve(tag: WalletRepoOperationsQueue.queueTag)
            let queue = DispatchQueue(label: "wallet.recovery.op.queue", qos: .userInitiated, target: targetQueue)
            return WalletRecoveryService(
                walletLogic: walletLogic,
                payloadCrypto: payloadCrypto,
                walletRepo: repo,
                walletPayloadRepository: payloadRepository,
                operationsQueue: queue
            )
        }

        factory { () -> WalletCreatorAPI in
            let targetQueue: DispatchQueue = DIKit.resolve(tag: WalletRepoOperationsQueue.queueTag)
            let queue = DispatchQueue(label: "wallet.creation.op.queue", qos: .userInitiated, target: targetQueue)
            return WalletCreator(
                entropyService: DIKit.resolve(),
                walletEncoder: DIKit.resolve(),
                encryptor: PayloadCrypto(cryptor: AESCryptor()),
                createWalletRepository: DIKit.resolve(),
                usedAccountsFinder: DIKit.resolve(),
                operationQueue: queue,
                uuidProvider: uuidProvider,
                generateWallet: generateWallet(context:),
                generateWrapper: generateWrapper(wallet:language:version:),
                checksumProvider: checksumHex(data:)
            )
        }

        factory { () -> SecondPasswordServiceAPI in
            SecondPasswordService(walletHolder: DIKit.resolve())
        }

        factory { () -> WalletMetadataEntryServiceAPI in
            let holder: WalletHolderAPI = DIKit.resolve()
            let metadata: MetadataServiceAPI = DIKit.resolve()
            let queue = DispatchQueue(label: "wallet.metadata.operations.queue")
            return WalletMetadataEntryService(
                walletHolder: holder,
                metadataService: metadata,
                queue: queue
            )
        }

        factory { () -> WalletConnectFetcherAPI in
            let metadataEntryService: WalletMetadataEntryServiceAPI = DIKit.resolve()
            return WalletConnectFetcher(
                metadataEntryService: metadataEntryService
            )
        }

        single { () -> UserCredentialsFetcherAPI in
            let metadataEntryService: WalletMetadataEntryServiceAPI = DIKit.resolve()
            return UserCredentialsFetcher(
                metadataEntryService: metadataEntryService
            )
        }

        single { () -> AccountCredentialsFetcherAPI in
            let metadataEntryService: WalletMetadataEntryServiceAPI = DIKit.resolve()
            let userCredentialsFetcher: UserCredentialsFetcherAPI = DIKit.resolve()
            return AccountCredentialsFetcher(
                metadataEntryService: metadataEntryService,
                userCredentialsFetcher: userCredentialsFetcher,
                featureFlagService: DIKit.resolve()
            )
        }

        factory { () -> BitcoinCashEntryFetcherAPI in
            let holder: WalletHolderAPI = DIKit.resolve()
            let metadata: WalletMetadataEntryServiceAPI = DIKit.resolve()
            return BitcoinCashEntryFetcher(
                walletHolder: holder,
                metadataEntryService: metadata
            )
        }

        factory { () -> BitcoinEntryFetcherAPI in
            let holder: WalletHolderAPI = DIKit.resolve()
            let metadata: WalletMetadataEntryServiceAPI = DIKit.resolve()
            return BitcoinEntryFetcher(
                walletHolder: holder,
                metadataEntryService: metadata
            )
        }

        factory { () -> RNGServiceAPI in
            let targetQueue: DispatchQueue = DIKit.resolve(tag: WalletRepoOperationsQueue.queueTag)
            let queue = DispatchQueue(label: "rng.service.op.queue", qos: .userInitiated, target: targetQueue)
            return RNGService(
                serverEntropyRepository: DIKit.resolve(),
                localEntropyProvider: provideLocalEntropy(bytes:),
                combineEntropyParsing: combineEntropies(local:remote:),
                operationQueue: queue
            )
        }

        factory { () -> WalletCoreHDWalletProvider in
            let walletHolder: WalletHolderAPI = DIKit.resolve()
            return provideWalletCoreHDWallet(
                walletHolder: walletHolder
            )
        }

        factory { () -> ChangePasswordServiceAPI in
            ChangePasswordService(
                walletSync: DIKit.resolve(),
                walletHolder: DIKit.resolve()
            )
        }

        factory { () -> VerifyMnemonicBackupServiceAPI in
            VerifyMnemonicBackupService(
                walletHolder: DIKit.resolve(),
                walletSync: DIKit.resolve(),
                walletRepo: DIKit.resolve()
            )
        }

        single { () -> MnemonicAccessAPI in
            MnemonicAccessProvider(
                legacyProvider: DIKit.resolve(),
                nativeProvider: DIKit.resolve(),
                nativeWalletFeatureFlag: { nativeWalletFlagEnabled() }
            )
        }

        factory { () -> MnemonicVerificationStatusProvider in
            provideMnemonicVerificationStatus(
                walletHolder: DIKit.resolve()
            )
        }

        factory { () -> NativeMnemonicAccessAPI in
            MnemonicAccessService(
                walletHolder: DIKit.resolve()
            )
        }

        factory { MnemonicComponentsProvider() as MnemonicComponentsProviding }

        factory { WalletCryptoService() as WalletCryptoServiceAPI }

        factory { WalletPayloadCryptor() as WalletPayloadCryptorAPI }

        factory { PayloadCrypto() as PayloadCryptoAPI }

        factory { AESCryptor() as AESCryptorAPI }

        // MARK: Wallet Upgrade

        factory { WalletUpgradeService() as WalletUpgradeServicing }

        factory { WalletUpgradeJSService() as WalletUpgradeJSServicing }
    }
    // swiftlint:enable closure_body_length
}
