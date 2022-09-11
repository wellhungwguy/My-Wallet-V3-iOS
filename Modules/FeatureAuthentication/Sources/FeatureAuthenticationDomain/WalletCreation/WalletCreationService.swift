// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import ToolKit
import WalletPayloadKit

public struct WalletCreatedContext: Equatable {
    public let guid: String
    public let sharedKey: String
    public let password: String
}

public typealias CreateWalletMethod = (
    _ email: String,
    _ password: String,
    _ accountName: String,
    _ recaptchaToken: String?
) -> AnyPublisher<WalletCreatedContext, WalletCreationServiceError>

public typealias ImportWalletMethod = (
    _ email: String,
    _ password: String,
    _ accountName: String,
    _ mnemonic: String
) -> AnyPublisher<Either<WalletCreatedContext, EmptyValue>, WalletCreationServiceError>

public typealias SetResidentialInfoMethod = (
    _ country: String,
    _ state: String?
) -> AnyPublisher<Void, Never>

public typealias UpdateCurrencyForNewWallets = (
    _ country: String,
    _ guid: String,
    _ sharedKey: String
) -> AnyPublisher<Void, Never>

public struct WalletCreationService {
    /// Creates a new wallet using the given details
    public var createWallet: CreateWalletMethod
    /// Imports and creates a new wallet using the given details
    public var importWallet: ImportWalletMethod
    /// Sets the residential info as part of account creation
    public var setResidentialInfo: SetResidentialInfoMethod
    /// Sets the default currency for a new wallet account
    public var updateCurrencyForNewWallets: UpdateCurrencyForNewWallets
}

extension WalletCreationService {

    // swiftlint:disable line_length
    public static func live(
        walletManager: WalletManagerAPI,
        walletCreator: WalletCreatorAPI,
        nabuRepository: NabuRepositoryAPI,
        updateCurrencyService: @escaping UpdateCurrencyForNewWallets,
        nativeWalletCreationEnabled: @escaping () -> AnyPublisher<Bool, Never>
    ) -> Self {
        let walletManager = walletManager
        let walletCreator = walletCreator
        let nativeWalletCreationEnabled = nativeWalletCreationEnabled
        return Self(
            createWallet: { email, password, accountName, token -> AnyPublisher<WalletCreatedContext, WalletCreationServiceError> in
                nativeWalletCreationEnabled()
                    .flatMap { isEnabled -> AnyPublisher<WalletCreatedContext, WalletCreationServiceError> in
                        guard isEnabled else {
                            return legacyCreation(
                                walletManager: walletManager,
                                email: email,
                                password: password
                            )
                            .eraseToAnyPublisher()
                        }
                        let siteKey = AuthenticationKeys.googleRecaptchaSiteKey
                        return walletCreator.createWallet(
                            email: email,
                            password: password,
                            accountName: accountName,
                            recaptchaToken: token,
                            siteKey: siteKey,
                            language: "en"
                        )
                        .mapError(WalletCreationServiceError.creationFailure)
                        .map(WalletCreatedContext.from(model:))
                        .eraseToAnyPublisher()
                    }
                    .eraseToAnyPublisher()
            },
            importWallet: { email, password, accountName, mnemonic -> AnyPublisher<Either<WalletCreatedContext, EmptyValue>, WalletCreationServiceError> in
                nativeWalletCreationEnabled()
                    .flatMap { isEnabled -> AnyPublisher<Either<WalletCreatedContext, EmptyValue>, WalletCreationServiceError> in
                        guard isEnabled else {
                            return legacyImportWallet(
                                email: email,
                                password: password,
                                mnemonic: mnemonic,
                                walletManager: walletManager
                            )
                            .map { _ -> Either<WalletCreatedContext, EmptyValue> in
                                // this makes me sad, for legacy JS code we ignore this as the loading of the wallet
                                // happens internally just after `didRecoverWallet` delegate method is called
                                .right(.noValue)
                            }
                            .mapError { _ in WalletCreationServiceError.creationFailure(.genericFailure) }
                            .eraseToAnyPublisher()
                        }
                        return walletCreator.importWallet(
                            mnemonic: mnemonic,
                            email: email,
                            password: password,
                            accountName: accountName,
                            language: "en"
                        )
                        .mapError(WalletCreationServiceError.creationFailure)
                        .map { model -> Either<WalletCreatedContext, EmptyValue> in
                            .left(WalletCreatedContext.from(model: model))
                        }
                        .eraseToAnyPublisher()
                    }
                    .eraseToAnyPublisher()
            },
            setResidentialInfo: { country, state -> AnyPublisher<Void, Never> in
                // we fire the request but we ignore the error,
                // even if this fails the user will still have to submit their details
                // as part of the KYC flow
                nabuRepository.setInitialResidentialInfo(
                    country: country,
                    state: state
                )
                .ignoreFailure()
            },
            updateCurrencyForNewWallets: { country, guid, sharedKey -> AnyPublisher<Void, Never> in
                // we ignore the failure since this is kind of a side effect for new wallets :(
                updateCurrencyService(country, guid, sharedKey)
                    .ignoreFailure(setFailureType: Never.self)
                    .eraseToAnyPublisher()
            }
        )
    }

    public static var noop: Self {
        Self(
            createWallet: { _, _, _, _ -> AnyPublisher<WalletCreatedContext, WalletCreationServiceError> in
                .empty()
            },
            importWallet: { _, _, _, _ -> AnyPublisher<Either<WalletCreatedContext, EmptyValue>, WalletCreationServiceError> in
                .empty()
            },
            setResidentialInfo: { _, _ -> AnyPublisher<Void, Never> in
                .empty()
            },
            updateCurrencyForNewWallets: { _, _, _ -> AnyPublisher<Void, Never> in
                .empty()
            }
        )
    }
}

// MARK: - Legacy Import

private func legacyImportWallet(
    email: String,
    password: String,
    mnemonic: String,
    walletManager: WalletManagerAPI
) -> AnyPublisher<EmptyValue, WalletError> {
    walletManager.loadWalletJS()
    walletManager.recover(
        email: email,
        password: password,
        seedPhrase: mnemonic
    )
    return listenForRecoveryEvents(walletManager: walletManager)
}

private func listenForRecoveryEvents(
    walletManager: WalletManagerAPI
) -> AnyPublisher<EmptyValue, WalletError> {
    let recovered = walletManager.walletRecovered
        .mapError { _ in WalletError.recovery(.failedToRecoverWallet) }
        .map { _ in EmptyValue.noValue }
        .eraseToAnyPublisher()

    // always fail upon receiving an event from `walletRecoveryFailed`
    let recoveryFailed = walletManager.walletRecoveryFailed
        .mapError { _ in WalletError.recovery(.failedToRecoverWallet) }
        .flatMap { _ -> AnyPublisher<EmptyValue, WalletError> in
            .failure(.recovery(.failedToRecoverWallet))
        }
        .eraseToAnyPublisher()

    return Publishers.Merge(recovered, recoveryFailed)
        .mapError { _ in WalletError.recovery(.failedToRecoverWallet) }
        .map { _ in .noValue }
        .eraseToAnyPublisher()
}

// MARK: - Legacy Creation

func legacyCreation(
    walletManager: WalletManagerAPI,
    email: String,
    password: String
) -> AnyPublisher<WalletCreatedContext, WalletCreationServiceError> {
    walletManager.loadWalletJS()
    walletManager.newWallet(password: password, email: email)

    return walletManager.didCreateNewAccount
        .flatMap { result -> AnyPublisher<WalletCreatedContext, WalletCreationServiceError> in
            switch result {
            case .success(let value):
                return .just(
                    WalletCreatedContext.from(model: value)
                )
                .eraseToAnyPublisher()
            case .failure(let error):
                return .failure(WalletCreationServiceError.creationFailure(.legacyError(error)))
            }
        }
        .eraseToAnyPublisher()
}

extension WalletCreatedContext {
    static func from(model: WalletCreation) -> Self {
        WalletCreatedContext(
            guid: model.guid,
            sharedKey: model.sharedKey,
            password: model.password
        )
    }
}
