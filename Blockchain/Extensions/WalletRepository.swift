// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import FeatureAuthenticationDomain
import PlatformKit
import RxRelay
import RxSwift
import ToolKit
import WalletPayloadKit

// TODO: Remove `NSObject` when `Wallet` is killed
/// A bridge to `Wallet` since it is an ObjC object.
@objc
final class WalletRepository: NSObject, WalletRepositoryAPI, WalletCredentialsProviding {

    // MARK: - Types

    private enum JSSetter {

        enum Password {
            static let change = "MyWalletPhone.changePassword(\"%@\")"
            static let success = "objc_on_change_password_success"
            static let error = "objc_on_change_password_error"
        }

        /// Accepts "true" / "false" as parameter
        static let syncPubKeys = "MyWalletPhone.setSyncPubKeys(%@)"

        /// Accepts a String representing the language
        static let language = "MyWalletPhone.setLanguage(\"%@\")"

        /// Accepts a String representing the wallet payload
        static let payload = "MyWalletPhone.setEncryptedWalletData(\"%@\")"

        /// Fetches the user offline token
        static let legacyOfflineToken = "MyWalletPhone.KYC.lifetimeToken()"

        /// Fetches the user id
        static let legacyUserId = "MyWalletPhone.KYC.userId()"

        /// Updates user credentials: userId, lifetimeToken
        static let updateUserCredentials = "MyWalletPhone.KYC.updateUserCredentials(\"%@\", \"%@\")"

        // MARK: Account Credentials

        static let updateAccountCredentials = "MyWalletPhone.accountCredentials.update(\"%@\", \"%@\", \"%@\", \"%@\")"

        /// Updates nabu credentials: userId, lifetimeToken
        static let updateNabuCredentials = "MyWalletPhone.accountCredentials.updateNabu(\"%@\", \"%@\")"

        /// Updates exchange credentials: userId, lifetimeToken
        static let updateExchangeCredentials = "MyWalletPhone.accountCredentials.updateExchange(\"%@\", \"%@\")"

        /// Fetches the user offline token
        static let nabuOfflineToken = "MyWalletPhone.accountCredentials.nabuLifetimeToken()"

        /// Fetches the user id
        static let nabuUserId = "MyWalletPhone.accountCredentials.nabuUserId()"

        /// Fetches the exchange offline token
        static let exchangeOfflineToken = "MyWalletPhone.accountCredentials.exchangeLifetimeToken()"

        /// Fetches the exchange user id
        static let exchangeUserId = "MyWalletPhone.accountCredentials.exchangeUserId()"
    }

    private enum JSCallback {
        static let updateUserCredentialsSuccess = "objc_updateUserCredentials_success"
        static let updateUserCredentialsFailure = "objc_updateUserCredentials_error"

        static let updateAccountCredentialsSuccess = "objc_updateAccountCredentials_success"
        static let updateAccountCredentialsFailure = "objc_updateAccountCredentials_error"

        static let updateNabuCredentialsSuccess = "objc_updateNabuCredentials_success"
        static let updateNabuCredentialsFailure = "objc_updateNabuCredentials_error"

        static let updateExchangeCredentialsSuccess = "objc_updateExchangeCredentials_success"
        static let updateExchangeCredentialsFailure = "objc_updateExchangeCredentials_error"
    }

    // MARK: - Properties

    private let sessionTokenRelay = BehaviorRelay<String?>(value: nil)
    private let authenticatorTypeRelay = BehaviorRelay<WalletAuthenticatorType>(value: .standard)
    private let passwordRelay = BehaviorRelay<String?>(value: nil)
    private let reactiveWallet: ReactiveWalletAPI

    /// Streams the GUID if exists
    var guid: AnyPublisher<String?, Never> {
        .just(settings.guid)
    }

    /// Streams the cached shared key or `nil` if it is not cached
    var sharedKey: AnyPublisher<String?, Never> {
        .just(settings.sharedKey)
    }

    /// Streams the session token if exists
    var sessionToken: AnyPublisher<String?, Never> {
        sessionTokenRelay.take(1).asPublisher().ignoreFailure()
    }

    /// Streams the authenticator type
    var authenticatorType: AnyPublisher<WalletAuthenticatorType, Never> {
        authenticatorTypeRelay.take(1).asPublisher().ignoreFailure()
    }

    /// Streams the password if exists
    var password: AnyPublisher<String?, Never> {
        passwordRelay.take(1).asPublisher().ignoreFailure()
    }

    var hasPassword: AnyPublisher<Bool, Never> {
        password
            .map { $0 != nil }
            .eraseToAnyPublisher()
    }

    /// Streams the nabu offline token
    var offlineToken: AnyPublisher<NabuOfflineToken, MissingCredentialsError> {
        reactiveWallet.waitUntilInitializedFirst
            .mapError()
            .flatMap { [weak self] _ -> AnyPublisher<NabuOfflineToken, MissingCredentialsError> in
                guard let self = self else {
                    return .failure(.offlineToken)
                }
                return self.getUnifiedOrLegacyNabuCredentials()
            }
            .eraseToAnyPublisher()
    }

    private let settings: AppSettingsAPI
    private let jsScheduler: SerialDispatchQueueScheduler
    private let combineJSScheduler: DispatchQueue
    private unowned let jsContextProvider: JSContextProviderAPI

    private let featureFlagService: FeatureFlagsServiceAPI

    // MARK: - Setup

    init(
        jsContextProvider: JSContextProviderAPI,
        appSettings: AppSettingsAPI,
        reactiveWallet: ReactiveWalletAPI,
        jsScheduler: SerialDispatchQueueScheduler = MainScheduler.instance,
        combineJSScheduler: DispatchQueue = DispatchQueue.main,
        featureFlagService: FeatureFlagsServiceAPI
    ) {
        self.jsContextProvider = jsContextProvider
        settings = appSettings
        self.reactiveWallet = reactiveWallet
        self.jsScheduler = jsScheduler
        self.combineJSScheduler = combineJSScheduler
        self.featureFlagService = featureFlagService
        super.init()
    }

    // MARK: - Wallet Setters

    /// Sets the guid
    func set(guid: String) -> AnyPublisher<Void, Never> {
        perform { [weak self] in
            self?.settings.set(guid: guid)
        }
    }

    /// Sets the shared key
    func set(sharedKey: String) -> AnyPublisher<Void, Never> {
        perform { [weak self] in
            self?.settings.set(sharedKey: sharedKey)
        }
    }

    /// Sets the session token
    func set(sessionToken: String) -> AnyPublisher<Void, Never> {
        perform { [weak sessionTokenRelay] in
            sessionTokenRelay?.accept(sessionToken)
        }
    }

    /// Clear the session token
    func cleanSessionToken() -> AnyPublisher<Void, Never> {
        perform { [weak sessionTokenRelay] in
            sessionTokenRelay?.accept(nil)
        }
    }

    /// Sets the authenticator type
    func set(authenticatorType: WalletAuthenticatorType) -> AnyPublisher<Void, Never> {
        perform { [weak authenticatorTypeRelay] in
            authenticatorTypeRelay?.accept(authenticatorType)
        }
    }

    /// Sets the password
    func set(password: String) -> AnyPublisher<Void, Never> {
        perform { [weak passwordRelay] in
            passwordRelay?.accept(password)
        }
    }

    // MARK: - JS Setters

    func set(language: String) -> AnyPublisher<Void, Never> {
        perform { [weak jsContextProvider] in
            let escaped = language.escapedForJS()
            let script = String(format: JSSetter.language, escaped)
            jsContextProvider?.jsContext.evaluateScriptCheckIsOnMainQueue(script)
        }
    }

    func set(syncPubKeys: Bool) -> AnyPublisher<Void, Never> {
        perform { [weak jsContextProvider] in
            let value = syncPubKeys ? "true" : "false"
            let script = String(format: JSSetter.syncPubKeys, value)
            jsContextProvider?.jsContext.evaluateScriptCheckIsOnMainQueue(script)
        }
    }

    func set(offlineToken: NabuOfflineToken) -> AnyPublisher<Void, CredentialWritingError> {
        featureFlagService.isEnabled(.accountCredentialsMetadataMigration)
            .flatMap { [weak self] isEnabled -> AnyPublisher<Void, CredentialWritingError> in
                guard let self = self else {
                    return .failure(.offlineToken)
                }
                guard isEnabled else {
                    return self.setLegacyUserCredentials(offlineToken: offlineToken)
                }
                // write to both old and new metadata.
                let unifiedSave = self.setUnifiedCredentialsOrJustNabu(offlineToken: offlineToken)
                let legacySave = self.setLegacyUserCredentials(offlineToken: offlineToken)
                return unifiedSave
                    .zip(legacySave)
                    .mapToVoid()
                    .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }

    func set(payload: String) -> AnyPublisher<Void, Never> {
        perform { [weak jsContextProvider] in
            let escaped = payload.escapedForJS()
            let script = String(format: JSSetter.payload, escaped)
            jsContextProvider?.jsContext.evaluateScriptCheckIsOnMainQueue(script)
        }
    }

    func changePassword(password: String) -> AnyPublisher<Void, PasswordRepositoryError> {
        set(password: password)
            .flatMap { [weak self] _ -> AnyPublisher<Void, PasswordRepositoryError> in
                guard let self = self else {
                    return .failure(.unavailable)
                }
                return self.sync()
            }
            .eraseToAnyPublisher()
    }

    private func sync() -> AnyPublisher<Void, PasswordRepositoryError> {
        Deferred {
            Future { [weak self] promise in
                guard let self = self else {
                    promise(.failure(.syncFailed))
                    return
                }
                guard let password = self.passwordRelay.value else {
                    promise(.failure(.unavailable))
                    return
                }

                let script = String(format: JSSetter.Password.change, password)

                self.jsContextProvider.jsContext.invokeOnce(functionBlock: {
                    promise(.success(()))
                }, forJsFunctionName: JSSetter.Password.success as NSString)

                self.jsContextProvider.jsContext.invokeOnce(functionBlock: {
                    promise(.failure(.syncFailed))
                }, forJsFunctionName: JSSetter.Password.error as NSString)

                self.jsContextProvider.jsContext.evaluateScriptCheckIsOnMainQueue(script)
            }
        }
        .subscribe(on: combineJSScheduler)
        .eraseToAnyPublisher()
    }

    // MARK: - Accessors

    /// Retrieves the nabu credentials from metadata via JS
    /// First tries to retrieves from the new `ACCOUNT_CREDENTIALS`, if that fails we fallback to `RETAIL_CORE`
    private func getUnifiedOrLegacyNabuCredentials() -> AnyPublisher<NabuOfflineToken, MissingCredentialsError> {
        featureFlagService.isEnabled(.accountCredentialsMetadataMigration)
            .flatMap { [weak self] isEnabled -> AnyPublisher<(String?, String?, String?, String?), WalletError> in
                guard let self = self else {
                    return .failure(.unknown)
                }
                guard isEnabled else {
                    let legacyUserId = self.getStringValueFromJS(script: JSSetter.legacyUserId)
                    let legacyOfflineToken = self.getStringValueFromJS(script: JSSetter.legacyOfflineToken)
                    return legacyUserId
                        .zip(legacyOfflineToken) { ($0, $1, nil, nil) }
                        .eraseToAnyPublisher()
                }
                // Try retrieving from unified credentials entry otherwise fallback to old entry
                let nabuUserId = self.getStringValueFromJS(script: JSSetter.nabuUserId)
                let nabuOfflineToken = self.getStringValueFromJS(script: JSSetter.nabuOfflineToken)

                let exchangeUserId = self.getStringValueFromJS(script: JSSetter.exchangeUserId)
                let exchangeOfflineToken = self.getStringValueFromJS(script: JSSetter.exchangeOfflineToken)

                let legacyUserId = self.getStringValueFromJS(script: JSSetter.legacyUserId)
                let legacyOfflineToken = self.getStringValueFromJS(script: JSSetter.legacyOfflineToken)

                return nabuUserId
                    .zip(nabuOfflineToken, exchangeUserId, exchangeOfflineToken)
                    .flatMap { userId, offlineToken, exchangeUserId, exchangeOfflineToken
                        -> AnyPublisher<(String?, String?, String?, String?), WalletError> in
                        guard let userId = userId,
                              let offlineToken = offlineToken
                        else {
                            return legacyUserId
                                .zip(legacyOfflineToken) { legacyUserId, legacyOfflineToken in
                                    (legacyUserId, legacyOfflineToken, nil, nil)
                                }
                                .eraseToAnyPublisher()
                        }
                        return .just((userId, offlineToken, exchangeUserId, exchangeOfflineToken))
                    }
                    .eraseToAnyPublisher()
            }
            .mapError { _ in MissingCredentialsError.offlineToken }
            .flatMap { nabuUserId, nabuOfflineToken, exchangeUserId, exchangeOfflineToken
                -> AnyPublisher<NabuOfflineToken, MissingCredentialsError> in
                guard let userId = nabuUserId else {
                    return .failure(.userId)
                }
                guard let offlineToken = nabuOfflineToken else {
                    return .failure(.offlineToken)
                }
                let token = NabuOfflineToken(
                    userId: userId,
                    token: offlineToken,
                    exchangeUserId: exchangeUserId,
                    exchangeOfflineToken: exchangeOfflineToken
                )
                return .just(token)
            }
            .eraseToAnyPublisher()
    }

    private func getStringValueFromJS(script: String) -> AnyPublisher<String?, WalletError> {
        let jsContextProvider = jsContextProvider
        return Deferred {
            Future { [jsContextProvider] promise in
                guard WalletManager.shared.wallet.isInitialized() else {
                    promise(.failure(.notInitialized))
                    return
                }
                guard let jsValue = jsContextProvider.jsContext.evaluateScriptCheckIsOnMainQueue(script) else {
                    promise(.success(nil))
                    return
                }
                guard !jsValue.isNull, !jsValue.isUndefined else {
                    promise(.success(nil))
                    return
                }
                guard !jsValue.isNull, !jsValue.isUndefined else {
                    promise(.success(nil))
                    return
                }
                guard let string = jsValue.toString() else {
                    promise(.success(nil))
                    return
                }
                guard !string.isEmpty else {
                    promise(.success(nil))
                    return
                }
                promise(.success(string))
            }
        }
        .subscribe(on: combineJSScheduler)
        .eraseToAnyPublisher()
    }

    private func setLegacyUserCredentials(
        offlineToken: NabuOfflineToken
    ) -> AnyPublisher<Void, CredentialWritingError> {
        let jsContextProvider = jsContextProvider
        return Deferred {
            Future { [jsContextProvider] promise in
                jsContextProvider.jsContext.invokeOnce(
                    functionBlock: {
                        promise(.failure(.offlineToken))
                    },
                    forJsFunctionName: JSCallback.updateUserCredentialsFailure as NSString
                )
                jsContextProvider.jsContext.invokeOnce(
                    functionBlock: {
                        promise(.success(()))
                    },
                    forJsFunctionName: JSCallback.updateUserCredentialsSuccess as NSString
                )
                let userId = offlineToken.userId.escapedForJS()
                let offlineToken = offlineToken.token.escapedForJS()
                let script = String(format: JSSetter.updateUserCredentials, userId, offlineToken)
                jsContextProvider.jsContext.evaluateScriptCheckIsOnMainQueue(script)
            }
        }
        .subscribe(on: combineJSScheduler)
        .eraseToAnyPublisher()
    }

    /// Sets the given offline token (userId, lifetimeToken) to new Metadata entry
    private func setNabuCredentials(
        offlineToken: NabuOfflineToken
    ) -> AnyPublisher<Void, CredentialWritingError> {
        let jsContextProvider = jsContextProvider
        return Deferred {
            Future { [jsContextProvider] promise in
                jsContextProvider.jsContext.invokeOnce(
                    functionBlock: {
                        promise(.failure(.offlineToken))
                    },
                    forJsFunctionName: JSCallback.updateNabuCredentialsFailure as NSString
                )
                jsContextProvider.jsContext.invokeOnce(
                    functionBlock: {
                        promise(.success(()))
                    },
                    forJsFunctionName: JSCallback.updateNabuCredentialsSuccess as NSString
                )
                let nabuUserId = offlineToken.userId.escapedForJS()
                let nabuOfflineToken = offlineToken.token.escapedForJS()
                let script = String(
                    format: JSSetter.updateNabuCredentials,
                    nabuUserId,
                    nabuOfflineToken
                )
                jsContextProvider.jsContext.evaluateScriptCheckIsOnMainQueue(script)
            }
        }
        .subscribe(on: combineJSScheduler)
        .eraseToAnyPublisher()
    }

    /// Sets the unified credentials if exchangeUserId/OfflineToken are non-nil
    /// otherwise just sets the nabu credentials
    private func setUnifiedCredentialsOrJustNabu(
        offlineToken: NabuOfflineToken
    ) -> AnyPublisher<Void, CredentialWritingError> {
        guard let exchangeUserId = offlineToken.exchangeUserId,
              let exchangeToken = offlineToken.exchangeOfflineToken
        else {
            return setNabuCredentials(offlineToken: offlineToken)
        }
        let jsContextProvider = jsContextProvider
        return Deferred {
            Future { [jsContextProvider] promise in
                jsContextProvider.jsContext.invokeOnce(
                    functionBlock: {
                        promise(.failure(.offlineToken))
                    },
                    forJsFunctionName: JSCallback.updateAccountCredentialsFailure as NSString
                )
                jsContextProvider.jsContext.invokeOnce(
                    functionBlock: {
                        promise(.success(()))
                    },
                    forJsFunctionName: JSCallback.updateAccountCredentialsSuccess as NSString
                )
                let nabuUserId = offlineToken.userId.escapedForJS()
                let nabuOfflineToken = offlineToken.token.escapedForJS()
                let exchangeUserId = exchangeUserId.escapedForJS()
                let exchangeToken = exchangeToken.escapedForJS()
                let script = String(
                    format: JSSetter.updateAccountCredentials,
                    nabuUserId,
                    nabuOfflineToken,
                    exchangeUserId,
                    exchangeToken
                )
                jsContextProvider.jsContext.evaluateScriptCheckIsOnMainQueue(script)
            }
        }
        .subscribe(on: combineJSScheduler)
        .eraseToAnyPublisher()
    }

    private func perform(_ operation: @escaping () -> Void) -> Completable {
        Completable
            .create { observer -> Disposable in
                operation()
                observer(.completed)
                return Disposables.create()
            }
            .subscribe(on: jsScheduler)
    }

    fileprivate func perform(_ operation: @escaping () -> Void) -> AnyPublisher<Void, Never> {
        Deferred {
            Future { promise in
                promise(.success(operation()))
            }
        }
        .subscribe(on: combineJSScheduler)
        .eraseToAnyPublisher()
    }

    fileprivate func perform<E: Error>(_ operation: @escaping () -> Void) -> AnyPublisher<Void, E> {
        let perform: AnyPublisher<Void, Never> = perform {
            operation()
        }
        return perform.mapError()
    }

    // MARK: - Legacy: PLEASE DONT USE THESE UNLESS YOU MUST HOOK LEGACY OBJ-C CODE

    @available(*, deprecated, message: "Please do not use this unless you absolutely need direct access")
    @objc
    var legacySessionToken: String? {
        get {
            sessionTokenRelay.value
        }
        set {
            sessionTokenRelay.accept(newValue)
        }
    }

    @available(*, deprecated, message: "Please do not use this unless you absolutely need direct access")
    @objc
    var legacyPassword: String? {
        get {
            passwordRelay.value
        }
        set {
            passwordRelay.accept(newValue)
        }
    }
}
