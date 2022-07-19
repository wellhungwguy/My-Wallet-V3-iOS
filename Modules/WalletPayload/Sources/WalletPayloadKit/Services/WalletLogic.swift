// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import DIKit
import Foundation
import MetadataKit
import ToolKit

protocol WalletLogicAPI {
    /// Initialises a `Wallet` using the given payload data
    /// - Parameter password: A `String` value representing user's password
    /// - Parameter secondPassword: A `String` value representing user's second password
    /// - Returns: `AnyPublisher<WalletState, WalletError>`
    func initialize(
        with password: String,
        secondPassword: String
    ) -> AnyPublisher<WalletState, WalletError>

    /// Initialises a `Wallet` using the given payload data
    /// - Parameter payload: A `WalletPayload` value
    /// - Parameter decryptedWallet: A `Data` value representing a valid decrypted wallet payload
    /// - Returns: `AnyPublisher<WalletState, WalletError>`
    func initialize(
        with password: String,
        payload: WalletPayload,
        decryptedWallet: Data
    ) -> AnyPublisher<WalletState, WalletError>

    /// Initialises a `Wallet` from metadata using the given seed phrase
    /// - Parameter mnemonic: A `String` value representing the users mnemonic words
    /// - Parameter queue: A `DispatchQueue` for operations to be performed on
    /// - Returns: `AnyPublisher<WalletState, WalletError>`
    func initialize(
        with mnemonic: String,
        on queue: DispatchQueue
    ) -> AnyPublisher<MetadataRecoveryCredentials, WalletError>

    /// Initialises a `Wallet` after recovery using the given payload data
    /// - Parameter password: A `String` value representing user's password
    /// - Parameter payload: A `WalletPayload` value
    /// - Parameter decryptedWallet: A `Data` value representing a valid decrypted wallet payload
    /// - Returns: `AnyPublisher<WalletState, WalletError>`
    func initializeAfterMetadataRecovery(
        with password: String,
        payload: WalletPayload,
        decryptedWallet: Data
    ) -> AnyPublisher<WalletState, WalletError>
}

final class WalletLogic: WalletLogicAPI {

    private let holder: WalletHolderAPI
    private let decoder: WalletDecoding
    private let upgrader: WalletUpgraderAPI
    private let metadata: MetadataServiceAPI
    private let walletSync: WalletSyncAPI
    private let notificationCenter: NotificationCenter
    private let logger: NativeWalletLoggerAPI
    private let payloadHealthChecker: PayloadHealthCheck

    #warning("TODO: This should be removed, pass opaque context from initialize methods instead")
    private var tempPassword: String?

    init(
        holder: WalletHolderAPI,
        decoder: @escaping WalletDecoding,
        upgrader: WalletUpgraderAPI,
        metadata: MetadataServiceAPI,
        walletSync: WalletSyncAPI,
        notificationCenter: NotificationCenter,
        logger: NativeWalletLoggerAPI,
        payloadHealthChecker: @escaping PayloadHealthCheck
    ) {
        self.holder = holder
        self.decoder = decoder
        self.upgrader = upgrader
        self.metadata = metadata
        self.walletSync = walletSync
        self.notificationCenter = notificationCenter
        self.logger = logger
        self.payloadHealthChecker = payloadHealthChecker
    }

    func initialize(
        with password: String,
        secondPassword: String
    ) -> AnyPublisher<WalletState, WalletError> {
        holder.walletStatePublisher
            .first()
            .flatMap { walletState -> AnyPublisher<WalletState, WalletError> in
                guard let walletState = walletState else {
                    return .failure(.payloadNotFound)
                }
                return .just(walletState)
            }
            .flatMap { walletState -> AnyPublisher<Wrapper, WalletError> in
                guard let wrapper = walletState.wrapper else {
                    return .failure(.initialization(.missingWallet))
                }
                return .just(wrapper)
            }
            .flatMap { [initialiseMetadataWithSecondPassword, tempPassword] wrapper
                -> AnyPublisher<WalletState, WalletError> in
                guard let tempPassword = tempPassword else {
                    return .failure(.initialization(.unknown))
                }
                return initialiseMetadataWithSecondPassword(wrapper, tempPassword, secondPassword)
            }
            .eraseToAnyPublisher()
    }

    func initialize(
        with password: String,
        payload: WalletPayload,
        decryptedWallet: Data
    ) -> AnyPublisher<WalletState, WalletError> {
        decodeAndPerformHealthCheck(
            payload: payload,
            decryptedWallet: decryptedWallet,
            decoder: decoder,
            payloadHealthCheck: payloadHealthChecker
        )
        .logMessageOnOutput(
            logger: logger,
            message: { wrapper in
                "Wrapper decoded from response: \(wrapper)"
            }
        )
        .flatMap { [upgrader, walletSync, logger] wrapper -> AnyPublisher<Wrapper, WalletError> in
            runUpgradeAndSyncIfNeeded(
                upgrader: upgrader,
                walletSync: walletSync,
                logger: logger,
                password: password,
                wrapper: wrapper
            )
        }
        .flatMap { [holder] wrapper -> AnyPublisher<Wrapper?, WalletError> in
            holder.hold(walletState: .partially(loaded: .justWrapper(wrapper)))
                .map(\.wrapper)
                .setFailureType(to: WalletError.self)
                .eraseToAnyPublisher()
        }
        .flatMap { wrapper -> AnyPublisher<Wrapper, WalletError> in
            guard let wrapper = wrapper else {
                return .failure(.initialization(.missingWallet))
            }
            return .just(wrapper)
        }
        .flatMap { [initialiseMetadata] wrapper -> AnyPublisher<WalletState, WalletError> in
            initialiseMetadata(wrapper, password)
        }
        .eraseToAnyPublisher()
    }

    func initializeAfterMetadataRecovery(
        with password: String,
        payload: WalletPayload,
        decryptedWallet: Data
    ) -> AnyPublisher<WalletState, WalletError> {
        holder.walletStatePublisher
            .first()
            .flatMap { walletState -> AnyPublisher<MetadataState, WalletError> in
                guard let metadataState = walletState?.metadata else {
                    return .failure(.initialization(.missingWallet))
                }
                return .just(metadataState)
            }
            .flatMap { [decoder, upgrader, walletSync, logger, payloadHealthChecker] metadataState
                -> AnyPublisher<(Wrapper, MetadataState), WalletError> in
                decodeAndPerformHealthCheck(
                    payload: payload,
                    decryptedWallet: decryptedWallet,
                    decoder: decoder,
                    payloadHealthCheck: payloadHealthChecker
                )
                .map { ($0, metadataState) }
                .flatMap { wrapper, metadataState -> AnyPublisher<(Wrapper, MetadataState), WalletError> in
                    runUpgradeAndSyncIfNeeded(
                        upgrader: upgrader,
                        walletSync: walletSync,
                        logger: logger,
                        password: password,
                        wrapper: wrapper
                    )
                    .map { upgradedWrapper in
                        // for clarity, we pass the upgraded wrapper.
                        (upgradedWrapper, metadataState)
                    }
                    .eraseToAnyPublisher()
                }
                .eraseToAnyPublisher()
            }
            .flatMap { [holder] wrapper, metadataState -> AnyPublisher<WalletState, WalletError> in
                holder.hold(walletState: .loaded(wrapper: wrapper, metadata: metadataState))
                    .first()
                    .mapError()
                    .eraseToAnyPublisher()
            }
            .handleEvents(receiveOutput: { [notifyReactiveWallet] _ in
                // inform ReactiveWallet that we're initialised
                notifyReactiveWallet()
            })
            .eraseToAnyPublisher()
    }

    func initialize(
        with mnemonic: String,
        on queue: DispatchQueue
    ) -> AnyPublisher<MetadataRecoveryCredentials, WalletError> {
        metadata.initializeAndRecoverCredentials(from: mnemonic)
            .subscribe(on: queue)
            .receive(on: queue)
            .mapError { error in WalletError.initialization(.metadataInitializationRecovery(error)) }
            .flatMap { [holder] context -> AnyPublisher<RecoveryContext, WalletError> in
                holder.hold(walletState: .partially(loaded: .justMetadata(context.metadataState)))
                    .setFailureType(to: WalletError.self)
                    .map { _ in context }
                    .first()
                    .eraseToAnyPublisher()
            }
            .map { context in
                MetadataRecoveryCredentials(
                    guid: context.guid,
                    sharedKey: context.sharedKey,
                    password: context.password
                )
            }
            .eraseToAnyPublisher()
    }

    // MARK: - Private

    private func initialiseMetadataWithSecondPassword(
        with wrapper: Wrapper,
        password: String,
        secondPassword: String
    ) -> AnyPublisher<WalletState, WalletError> {
        guard wrapper.wallet.doubleEncrypted else {
            fatalError("This method should only be called if a secondPassword is needed")
        }
        return initialiseMetadata(with: wrapper, password: password, secondPassword: secondPassword)
    }

    private func initialiseMetadata(
        with wrapper: Wrapper,
        password: String
    ) -> AnyPublisher<WalletState, WalletError> {
        if wrapper.wallet.doubleEncrypted {
            tempPassword = password
            return .failure(.initialization(.needsSecondPassword))
        }
        return initialiseMetadata(with: wrapper, password: password, secondPassword: nil)
    }

    private func initialiseMetadata(
        with wrapper: Wrapper,
        password: String,
        secondPassword: String?
    ) -> AnyPublisher<WalletState, WalletError> {
        provideMetadataInput(
            password: password,
            secondPassword: secondPassword,
            wallet: wrapper.wallet
        )
        .map { input in
            (input, wrapper)
        }
        .flatMap { [metadata, logger] input, wrapper -> AnyPublisher<WalletState, WalletError> in
            metadata.initialize(
                credentials: input.credentials,
                masterKey: input.masterKey,
                payloadIsDoubleEncrypted: input.payloadIsDoubleEncrypted
            )
            .logMessageOnOutput(logger: logger, message: { _ in
                "Metadata initialized"
            })
            .map { metadataState -> WalletState in
                .loaded(wrapper: wrapper, metadata: metadataState)
            }
            .mapError { error in .initialization(.metadataInitialization(error)) }
            .eraseToAnyPublisher()
        }
        .flatMap { [holder] walletState
            -> AnyPublisher<WalletState, WalletError> in
            holder.hold(walletState: walletState)
                .setFailureType(to: WalletError.self)
                .eraseToAnyPublisher()
        }
        .handleEvents(receiveOutput: { [notifyReactiveWallet] _ in
            // inform ReactiveWallet that we're initialised
            notifyReactiveWallet()
        })
        .eraseToAnyPublisher()
    }

    private func notifyReactiveWallet() {
        notificationCenter.post(Notification(name: .walletInitialized))
        notificationCenter.post(Notification(name: .walletMetadataLoaded))
    }
}

private func decodeAndPerformHealthCheck(
    payload: WalletPayload,
    decryptedWallet: Data,
    decoder: @escaping WalletDecoding,
    payloadHealthCheck: @escaping PayloadHealthCheck
) -> AnyPublisher<Wrapper, WalletError> {
    decoder(payload, decryptedWallet)
        .flatMap { wrapper -> AnyPublisher<Wrapper, WalletError> in
            payloadHealthCheck(wrapper)
                .eraseToAnyPublisher()
        }
        .eraseToAnyPublisher()
}

/// Runs upgrades on the given `Wrapper` and syncs with server, if needed
/// - Parameters:
///   - upgrader: A `WalletUpgraderAPI` object responsible for the upgrades
///   - wrapper: A `Wrapper` to be upgraded
/// - Returns: The upgraded wrapper, `AnyPublisher<Wrapper, WalletError>`
private func runUpgradeAndSyncIfNeeded(
    upgrader: WalletUpgraderAPI,
    walletSync: WalletSyncAPI,
    logger: NativeWalletLoggerAPI,
    password: String,
    wrapper: Wrapper
) -> AnyPublisher<Wrapper, WalletError> {
    guard upgrader.upgradedNeeded(wrapper: wrapper) else {
        logger.log(message: "Skipping wallet upgrade", metadata: nil)
        return .just(wrapper)
    }
    return upgrader.performUpgrade(wrapper: wrapper)
        .mapError(WalletError.upgrade)
        .logMessageOnOutput(logger: logger, message: { wrapper in
            "!¡! Upgraded wrapper to be sync: \(wrapper)"
        })
        .flatMap { wrapper -> AnyPublisher<Wrapper, WalletError> in
            walletSync.sync(wrapper: wrapper, password: password)
                .map { _ in wrapper }
                .mapError(WalletError.sync)
                .eraseToAnyPublisher()
        }
        .logMessageOnOutput(logger: logger, message: { _ in
            "Upgraded wrapper synced"
        })
        .eraseToAnyPublisher()
}

// MARK: - Metadata Input

struct MetadataInput {
    let credentials: Credentials
    let masterKey: MasterKey
    let payloadIsDoubleEncrypted: Bool
}

func provideMetadataInput(
    password: String,
    secondPassword: String?,
    wallet: NativeWallet
) -> AnyPublisher<MetadataInput, WalletError> {
    getSeedHex(from: wallet, secondPassword: secondPassword)
        .flatMap(masterKeyFrom(seedHex:))
        .map { masterKey -> MetadataInput in
            let credentials = Credentials(
                guid: wallet.guid,
                sharedKey: wallet.sharedKey,
                password: password
            )
            return MetadataInput(
                credentials: credentials,
                masterKey: masterKey,
                payloadIsDoubleEncrypted: wallet.doubleEncrypted
            )
        }
        .publisher
        .eraseToAnyPublisher()
}

private func masterKeyFrom(seedHex: String) -> Result<MasterKey, WalletError> {
    MasterKey.from(seedHex: seedHex)
        .mapError { _ -> WalletError in
            .initialization(.unknown)
        }
}
