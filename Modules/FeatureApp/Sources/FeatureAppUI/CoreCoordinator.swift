// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import AnalyticsKit
import BlockchainNamespace
import Combine
import ComposableArchitecture
import DelegatedSelfCustodyDomain
import ERC20Kit
import FeatureAppDomain
import FeatureAppUpgradeDomain
import FeatureAppUpgradeUI
import FeatureAuthenticationDomain
import FeatureAuthenticationUI
import FeatureSettingsDomain
import Localization
import ObservabilityKit
import PlatformKit
import PlatformUIKit
import RemoteNotificationsKit
import ToolKit
import UIKit
import WalletPayloadKit

// swiftlint:disable file_length
// swiftformat:disable indent

public struct CoreAppState: Equatable {
    public var onboarding: Onboarding.State? = .init()
    public var loggedIn: LoggedIn.State?
    public var deviceAuthorization: AuthorizeDeviceState?

    public var alertState: AlertState<CoreAppAction>?

    var isLoggedIn: Bool {
        onboarding == nil && loggedIn != nil
    }

    public init(
        onboarding: Onboarding.State? = .init(),
        loggedIn: LoggedIn.State? = nil,
        deviceAuthorization: AuthorizeDeviceState? = nil
    ) {
        self.onboarding = onboarding
        self.loggedIn = loggedIn
        self.deviceAuthorization = deviceAuthorization
    }
}

public enum ProceedToLoggedInError: Error, Equatable {
    case coincore(CoincoreError)
}

public indirect enum CoreAlertAction: Equatable {
    public struct Buttons: Equatable {
        let primary: AlertState<CoreAppAction>.Button
        let secondary: AlertState<CoreAppAction>.Button?
    }

    case show(title: String, message: String, buttons: Buttons?)
    case dismiss
    case openAppStore
}

public enum CoreAppAction: Equatable {
    case start
    case loggedIn(LoggedIn.Action)
    case onboarding(Onboarding.Action)
    case prepareForLoggedIn
    case fetchedUser(Result<NabuUser, NabuUserServiceError>)
    case proceedToLoggedIn(Result<Bool, ProceedToLoggedInError>)
    case appForegrounded
    case deeplink(DeeplinkOutcome)
    case requirePin
    case setupPin
    case alert(CoreAlertAction)

    // Wallet Authentication
    case wallet(WalletAction)
    case fetchWallet(password: String)
    case doFetchWallet(password: String)
    case authenticate
    case didDecryptWallet(WalletDecryption)
    case decryptionFailure(AuthenticationError)
    case authenticated(Result<Bool, AuthenticationError>)
    case initializeWallet
    case walletInitialized
    case checkWalletUpgrade
    case walletNeedsUpgrade(Bool)

    // Device Authorization
    case authorizeDevice(AuthorizeDeviceAction)
    case loginRequestReceived(deeplink: URL)
    case checkIfConfirmationRequired(sessionId: String, base64Str: String)
    case proceedToDeviceAuthorization(LoginRequestInfo)
    case deviceAuthorizationFinished

    // Account Recovery
    case resetPassword(newPassword: String)

    // Nabu Account Operations
    case resetVerificationStatusIfNeeded(guid: String?, sharedKey: String?)

    // Mobile Auth Sync
    case mobileAuthSync(isLogin: Bool)

    case none
}

struct CoreAppEnvironment {
    var accountRecoveryService: AccountRecoveryServiceAPI
    var alertPresenter: AlertViewPresenterAPI
    var analyticsRecorder: AnalyticsEventRecorderAPI
    var app: AppProtocol
    var appStoreOpener: AppStoreOpening
    var appUpgradeState: () -> AnyPublisher<AppUpgradeState?, Never>
    var blockchainSettings: BlockchainSettingsAppAPI
    var buildVersionProvider: () -> String
    var coincore: CoincoreAPI
    var credentialsStore: CredentialsStoreAPI
    var deeplinkHandler: DeepLinkHandling
    var deeplinkRouter: DeepLinkRouting
    var delegatedCustodySubscriptionsService: DelegatedCustodySubscriptionsServiceAPI
    var deviceVerificationService: DeviceVerificationServiceAPI
    var erc20CryptoAssetService: ERC20CryptoAssetServiceAPI
    var exchangeRepository: ExchangeAccountRepositoryAPI
    var externalAppOpener: ExternalAppOpener
    var featureFlagsService: FeatureFlagsServiceAPI
    var fiatCurrencySettingsService: FiatCurrencySettingsServiceAPI
    var forgetWalletService: ForgetWalletService
    var loadingViewPresenter: LoadingViewPresenting
    var mainQueue: AnySchedulerOf<DispatchQueue>
    var mobileAuthSyncService: MobileAuthSyncServiceAPI
    var nabuUserService: NabuUserServiceAPI
    var nativeWalletFlagEnabled: () -> AnyPublisher<Bool, Never>
    var performanceTracing: PerformanceTracingServiceAPI
    var pushNotificationsRepository: PushNotificationsRepositoryAPI
    var remoteNotificationServiceContainer: RemoteNotificationServiceContaining
    var resetPasswordService: ResetPasswordServiceAPI
    var secondPasswordPrompter: SecondPasswordPromptable
    var sharedContainer: SharedContainerUserDefaults
    var siftService: FeatureAuthenticationDomain.SiftServiceAPI
    var walletManager: WalletManagerAPI
    var walletPayloadService: WalletPayloadServiceAPI
    var walletService: WalletService
    var walletStateProvider: WalletStateProvider
    var walletUpgradeService: WalletUpgradeServicing
}

let mainAppReducer = Reducer<CoreAppState, CoreAppAction, CoreAppEnvironment>.combine(
    onBoardingReducer
        .optional()
        .pullback(
            state: \.onboarding,
            action: /CoreAppAction.onboarding,
            environment: { environment -> Onboarding.Environment in
                Onboarding.Environment(
                    app: environment.app,
                    appSettings: environment.blockchainSettings,
                    credentialsStore: environment.credentialsStore,
                    alertPresenter: environment.alertPresenter,
                    mainQueue: environment.mainQueue,
                    deviceVerificationService: environment.deviceVerificationService,
                    walletManager: environment.walletManager,
                    mobileAuthSyncService: environment.mobileAuthSyncService,
                    pushNotificationsRepository: environment.pushNotificationsRepository,
                    walletPayloadService: environment.walletPayloadService,
                    featureFlagsService: environment.featureFlagsService,
                    externalAppOpener: environment.externalAppOpener,
                    forgetWalletService: environment.forgetWalletService,
                    buildVersionProvider: environment.buildVersionProvider,
                    appUpgradeState: environment.appUpgradeState
                )
            }
        ),
    loggedInReducer
        .optional()
        .pullback(
            state: \.loggedIn,
            action: /CoreAppAction.loggedIn,
            environment: { environment -> LoggedIn.Environment in
                LoggedIn.Environment(
                    analyticsRecorder: environment.analyticsRecorder,
                    app: environment.app,
                    appSettings: environment.blockchainSettings,
                    deeplinkRouter: environment.deeplinkRouter,
                    exchangeRepository: environment.exchangeRepository,
                    featureFlagsService: environment.featureFlagsService,
                    fiatCurrencySettingsService: environment.fiatCurrencySettingsService,
                    loadingViewPresenter: environment.loadingViewPresenter,
                    mainQueue: environment.mainQueue,
                    nabuUserService: environment.nabuUserService,
                    performanceTracing: environment.performanceTracing,
                    remoteNotificationAuthorizer: environment.remoteNotificationServiceContainer.authorizer,
                    remoteNotificationTokenSender: environment.remoteNotificationServiceContainer.tokenSender,
                    walletManager: environment.walletManager
                )
            }
        ),
    authorizeDeviceReducer
        .optional()
        .pullback(
            state: \.deviceAuthorization,
            action: /CoreAppAction.authorizeDevice,
            environment: {
                AuthorizeDeviceEnvironment(
                    mainQueue: $0.mainQueue,
                    deviceVerificationService: $0.deviceVerificationService
                )
            }
        ),
    mainAppReducerCore
)

// swiftlint:disable closure_body_length
let mainAppReducerCore = Reducer<CoreAppState, CoreAppAction, CoreAppEnvironment> { state, action, environment in
    switch action {
    case .start:
        return .fireAndForget {
            syncPinKeyWithICloud(
                blockchainSettings: environment.blockchainSettings,
                credentialsStore: environment.credentialsStore
            )
        }

    case .appForegrounded:
        let isLoggedIn = state.isLoggedIn
        return environment.nativeWalletFlagEnabled()
            .flatMap { isEnabled -> AnyPublisher<Bool, Never> in
                guard isEnabled else {
                    return .just(environment.walletManager.walletIsInitialized())
                }
                return environment.walletStateProvider
                    .isWalletInitializedPublisher()
            }
            .receive(on: environment.mainQueue)
            .flatMap { isWalletInitialized -> Effect<CoreAppAction, Never> in
                // check if we need to display the pin for authentication
                guard isWalletInitialized else {
                    // do nothing if we're on the authentication state,
                    // meaning we either need to register, login or recover
                    guard isLoggedIn else {
                        return Effect.cancel(id: WalletCancelations.ForegroundInitCheckId())
                    }
                    // We need to send the `stop` action prior we show the pin entry,
                    // this clears any running operation from the logged-in state.
                    return .concatenate(
                        Effect(value: .loggedIn(.stop)),
                        Effect(value: .requirePin)
                    )
                }
                return Effect.cancel(id: WalletCancelations.ForegroundInitCheckId())
            }
            .eraseToEffect()
            .cancellable(id: WalletCancelations.ForegroundInitCheckId(), cancelInFlight: true)

    case .deeplink(.handleLink(let content)) where content.context == .dynamicLinks:
        // for context this performs side-effect to values in the appSettings
        // it'll then be up to the `DeeplinkRouter` to capture any of these changes
        // and route if needed, the router is handled once we're in a logged-in state
        environment.deeplinkHandler.handle(deepLink: content.url.absoluteString)
        return .none

    case .deeplink(.handleLink(let content)) where content.context.usableOnlyDuringAuthentication:
        // currently we only support only one deeplink for login, so being naive here
        guard content.context == .blockchainLinks(.login) else {
            return .none
        }
        // handle deeplink if we've entered verify device flow
        if let onboarding = state.onboarding,
           let authState = onboarding.welcomeState,
           let loginState = authState.emailLoginState,
           loginState.verifyDeviceState != nil
        {
            // Pass content to welcomeScreen to be handled
            return Effect(value: .onboarding(.welcomeScreen(.deeplinkReceived(content.url))))
        } else {
            return Effect(value: .loginRequestReceived(deeplink: content.url))
        }

    case .deeplink(.handleLink(let content)):
        // we first check if we're logged in, if not we need to defer the deeplink routing
        guard state.isLoggedIn else {
            // continue if we're on the onboarding state
            guard let onboarding = state.onboarding else {
                return .none
            }
            // check if we're on the pinState and we need the user to enter their pin
            if let pinState = onboarding.pinState,
               pinState.requiresPinAuthentication,
               !content.context.usableOnlyDuringAuthentication
            {
                // defer the deeplink until we handle the `.proceedToLoggedIn` action
                state.onboarding?.deeplinkContent = content
            }
            return .none
        }
        // continue with the deeplink
        return Effect(value: .loggedIn(.deeplink(content)))

    case .deeplink(.informAppNeedsUpdate):
        let buttons: CoreAlertAction.Buttons = .init(
            primary: .default(
                TextState(verbatim: LocalizationConstants.DeepLink.updateNow),
                action: .send(.alert(.openAppStore))
            ),
            secondary: .cancel(
                TextState(verbatim: LocalizationConstants.cancel),
                action: .send(.alert(.dismiss))
            )
        )
        let alertAction = CoreAlertAction.show(
            title: LocalizationConstants.DeepLink.deepLinkUpdateTitle,
            message: LocalizationConstants.DeepLink.deepLinkUpdateMessage,
            buttons: buttons
        )
        return Effect(value: .alert(alertAction))

    case .deeplink(.ignore):
        return .none

    case .requirePin:
        state.loggedIn = nil
        state.onboarding = Onboarding.State(pinState: .init())
        return .merge(
            .cancel(id: WalletCancelations.ForegroundInitCheckId()),
            Effect(value: .onboarding(.start))
        )

    case .fetchWallet(let password):
        environment.loadingViewPresenter.showCircular()
        return environment.nativeWalletFlagEnabled()
            .flatMap { nativeWalletEnabled -> Effect<CoreAppAction, Never> in
                guard nativeWalletEnabled else {
                    // As much as I (Dimitris) hate delay-ing work this is one of those method
                    // that I'm going to make an exception, mainly because it's going to be replaced soon.
                    // This is to give a change for the circular loader to appear before
                    // we call `fetch(with: _password_)` which will call the evil that is JS.
                    return .merge(
                        Effect(value: .doFetchWallet(password: password))
                            .delay(for: .milliseconds(200), scheduler: environment.mainQueue)
                            .eraseToEffect()
                            .cancellable(id: WalletCancelations.FetchId(), cancelInFlight: true),
                        Effect(value: .authenticate)
                    )
                }
                return Effect(value: .doFetchWallet(password: password))
            }
            .eraseToEffect()

    case .doFetchWallet(let password):
        let walletManager = environment.walletManager
        let walletService = environment.walletService
        let mainQueue = environment.mainQueue
        return environment.nativeWalletFlagEnabled()
            .flatMap { nativeWalletEnabled -> Effect<CoreAppAction, Never> in
                guard nativeWalletEnabled else {
                    walletManager.fetch(with: password)
                    return .cancel(id: WalletCancelations.FetchId())
                }
                // Runs the native wallet fetching
                return walletService.fetch(password)
                    .receive(on: mainQueue)
                    .catchToEffect()
                    .cancellable(id: WalletCancelations.FetchId(), cancelInFlight: true)
                    .map { CoreAppAction.wallet(.walletFetched($0)) }
            }
            .eraseToEffect()

    case .authenticate:
        return .merge(
            environment.walletManager.didDecryptWallet
                .receive(on: environment.mainQueue)
                .catchToEffect()
                .cancellable(id: WalletCancelations.DecryptId(), cancelInFlight: false)
                .map { result -> CoreAppAction in
                    guard case .success(let value) = result else {
                        return .none
                    }
                    return handleWalletDecryption(value)
                },
            environment.walletManager.didCompleteAuthentication
                .receive(on: environment.mainQueue)
                .catchToEffect()
                .cancellable(id: WalletCancelations.AuthenticationId(), cancelInFlight: false)
                .map { result -> CoreAppAction in
                    guard case .success(let value) = result else {
                        return CoreAppAction.authenticated(
                            .failure(.init(code: AuthenticationError.ErrorCode.unknown))
                        )
                    }
                    return CoreAppAction.authenticated(value)
                }
        )

    case .didDecryptWallet(let decryption):
        // defer showing the loading spinner, we should find a better way of dealing with this
        // for context the underlying implementation of showing the circular loader
        // relies on attaching the loader to the top window's view!!, this is error-prone and there are cases
        // where the loader would not show above a presented view controller...
        environment.loadingViewPresenter.hide()

        // skip saving guid and sharedKey if we detect a second password is needed
        // TODO: Refactor this so that we don't call legacy methods directly
        if environment.walletManager.walletNeedsSecondPassword(),
           state.onboarding?.welcomeState != nil
        {
            return .cancel(id: WalletCancelations.DecryptId())
        }

        environment.loadingViewPresenter.showCircular()
        environment.blockchainSettings.guid = decryption.guid
        environment.blockchainSettings.sharedKey = decryption.sharedKey

        return .merge(
            // reset KYC verification if decrypted wallet under recovery context
            Effect(value: .resetVerificationStatusIfNeeded(
                guid: decryption.guid,
                sharedKey: decryption.sharedKey
            )),
            .cancel(id: WalletCancelations.DecryptId()),
            .fireAndForget {
                clearPinIfNeeded(
                    for: decryption.passwordPartHash,
                    appSettings: environment.blockchainSettings
                )
            }
        )

    case .decryptionFailure(let error):
        state.onboarding?.displayAlert = .walletAuthentication(error)
        return .cancel(id: WalletCancelations.DecryptId())

    case .authenticated(.failure(let error)) where error.code == .failedToLoadWallet:
        guard state.onboarding?.welcomeState != nil else {
            state.onboarding?.displayAlert = .walletAuthentication(error)
            return .merge(
                .cancel(id: WalletCancelations.AuthenticationId()),
                Effect(value: .onboarding(.pin(.logout)))
            )
        }
        if state.onboarding?.welcomeState?.manualCredentialsState != nil {
            return .merge(
                .cancel(id: WalletCancelations.AuthenticationId()),
                Effect(
                    value: CoreAppAction.onboarding(
                        .welcomeScreen(
                            .manualPairing(
                                .password(
                                    .showIncorrectPasswordError(true)
                                )
                            )
                        )
                    )
                )
            )
        }
        return .merge(
            .cancel(id: WalletCancelations.AuthenticationId()),
            Effect(
                value: CoreAppAction.onboarding(
                    .welcomeScreen(
                        .emailLogin(
                            .verifyDevice(
                                .credentials(
                                    .password(
                                        .showIncorrectPasswordError(true)
                                    )
                                )
                            )
                        )
                    )
                )
            )
        )

    case .authenticated(.failure(let error)):
        state.onboarding?.displayAlert = .walletAuthentication(error)
        return .cancel(id: WalletCancelations.AuthenticationId())

    case .authenticated(.success):
        // when on authenticated success we need to check if the wallet
        // requires a second password, if we do then we stop the process
        // and display a notice to the user
        // TODO: Refactor this so that we don't call legacy methods directly
        if environment.walletManager.walletNeedsSecondPassword(),
           state.onboarding?.welcomeState != nil
        {
            // unfortunately during login we store the guid in the settings
            // we need to reset this if we detect a second password
            environment.blockchainSettings.guid = nil
            environment.blockchainSettings.sharedKey = nil
            return .merge(
                .cancel(id: WalletCancelations.AuthenticationId()),
                Effect(
                    value: .onboarding(.informSecondPasswordDetected)
                )
            )
        }
        // decide if we need to reset password or not (we need to reset password after metadata recovery)
        // if needed, go to reset password screen, if not, go to PIN screen
        if let context = state.onboarding?.walletRecoveryContext,
           context == .metadataRecovery
        {
            environment.loadingViewPresenter.hide()
            return .merge(
                .cancel(id: WalletCancelations.AuthenticationId()),
                Effect(value: .onboarding(.handleMetadataRecoveryAfterAuthentication))
            )
        }
        // decide if we need to set a pin or not
        guard environment.blockchainSettings.isPinSet else {
            guard state.onboarding?.welcomeState != nil else {
                return .merge(
                    .cancel(id: WalletCancelations.AuthenticationId()),
                    Effect(value: .setupPin)
                )
            }
            return .merge(
                .cancel(id: WalletCancelations.AuthenticationId()),
                Effect(value: .onboarding(.welcomeScreen(.dismiss()))),
                Effect(value: .setupPin)
            )
        }
        return .merge(
            .cancel(id: WalletCancelations.AuthenticationId()),
            Effect(value: .initializeWallet)
        )

    case .setupPin:
        environment.loadingViewPresenter.hide()
        state.onboarding?.pinState = .init()
        state.onboarding?.passwordRequiredState = nil
        return Effect(value: CoreAppAction.onboarding(.pin(.create)))

    case .initializeWallet:
        return environment.walletManager
            .reactiveWallet
            .waitUntilInitializedFirst
            .receive(on: environment.mainQueue)
            .catchToEffect()
            .cancellable(id: WalletCancelations.InitializationId(), cancelInFlight: false)
            .map { _ in CoreAppAction.walletInitialized }

    case .walletInitialized:
        return Effect(value: .checkWalletUpgrade)

    case .checkWalletUpgrade:
        return environment.walletUpgradeService
            .needsWalletUpgrade
            .receive(on: environment.mainQueue)
            .catchToEffect()
            .cancellable(id: WalletCancelations.UpgradeId(), cancelInFlight: false)
            .map { result -> CoreAppAction in
                guard case .success(let shouldUpgrade) = result else {
                    // impossible with current `WalletUpgradeServicing` implementation
                    return CoreAppAction.prepareForLoggedIn
                }
                return CoreAppAction.walletNeedsUpgrade(shouldUpgrade)
            }

    case .walletNeedsUpgrade(let shouldUpgrade):
        // check if we need the wallet needs an upgrade otherwise proceed to logged in state
        guard shouldUpgrade else {
            return Effect(value: CoreAppAction.prepareForLoggedIn)
        }
        environment.loadingViewPresenter.hide()
        state.onboarding?.pinState = nil
        state.onboarding?.walletUpgradeState = WalletUpgrade.State()
        return .merge(
            .cancel(id: WalletCancelations.InitializationId()),
            .cancel(id: WalletCancelations.UpgradeId()),
            Effect(value: CoreAppAction.onboarding(.walletUpgrade(.begin)))
        )

    case .loginRequestReceived(let deeplink):
        return environment
            .featureFlagsService
            .isEnabled(.pollingForEmailLogin)
            .flatMap { isEnabled -> Effect<CoreAppAction, Never> in
                guard isEnabled else {
                    return .none
                }
                return environment
                    .deviceVerificationService
                    .handleLoginRequestDeeplink(url: deeplink)
                    .receive(on: environment.mainQueue)
                    .catchToEffect()
                    .map { result -> CoreAppAction in
                        guard case .failure(let error) = result else {
                            // if success, just ignore the effect
                            return .none
                        }
                        switch error {
                        // when catched a deeplink with a different session token,
                        // or when there is no session token from the app,
                        // it means a login magic link generated from a different device is catched
                        // proceed to login request authorization in this case
                        case .missingSessionToken(let sessionId, let base64Str),
                             .sessionTokenMismatch(let sessionId, let base64Str):
                            return .checkIfConfirmationRequired(sessionId: sessionId, base64Str: base64Str)
                        case .failToDecodeBase64Component,
                             .failToDecodeToWalletInfo:
                            return .none
                        }
                    }
            }
            .eraseToEffect()

    case .onboarding(.welcomeScreen(.emailLogin(.verifyDevice(.checkIfConfirmationRequired(let sessionId, let base64Str))))),
         .checkIfConfirmationRequired(let sessionId, let base64Str):
        return environment
            .deviceVerificationService
            // trigger confirmation required error
            .authorizeVerifyDevice(from: sessionId, payload: base64Str, confirmDevice: nil)
            .receive(on: environment.mainQueue)
            .catchToEffect()
            .map { result -> CoreAppAction in
                guard case .failure(let error) = result else {
                    return .none
                }
                switch error {
                case .confirmationRequired(let timestamp, let details):
                    let info = LoginRequestInfo(
                        sessionId: sessionId,
                        base64Str: base64Str,
                        details: details,
                        timestamp: timestamp
                    )
                    return .proceedToDeviceAuthorization(info)
                default:
                    return .none
                }
            }

    case .proceedToDeviceAuthorization(let loginRequestInfo):
        state.deviceAuthorization = .init(
            loginRequestInfo: loginRequestInfo
        )
        return .none

    case .deviceAuthorizationFinished:
        state.deviceAuthorization = nil
        return .none

    case .prepareForLoggedIn:
        return environment.nabuUserService.fetchUser()
            .receive(on: environment.mainQueue)
            .catchToEffect()
            .map(CoreAppAction.fetchedUser)
    case .fetchedUser:
        let coincoreInit = environment.coincore
            .initialize()
            .mapError(ProceedToLoggedInError.coincore)
        return coincoreInit
            .flatMap { [environment] _ in
                environment.erc20CryptoAssetService
                    .initialize()
                    .replaceError(with: ())
                    .eraseToAnyPublisher()
            }
            .flatMap { [environment] _ in
                environment.delegatedCustodySubscriptionsService
                    .subscribe()
                    .replaceError(with: ())
                    .eraseToAnyPublisher()
            }
            .receive(on: environment.mainQueue)
            .catchToEffect { result in
                switch result {
                case .failure(let error):
                    return .failure(error)
                case .success:
                    return .success(true)
                }
            }
            .cancellable(id: WalletCancelations.AssetInitializationId(), cancelInFlight: false)
            .map(CoreAppAction.proceedToLoggedIn)

    case .proceedToLoggedIn(.failure(let error)):
        state.onboarding?.displayAlert = .proceedToLoggedIn(error)
        return .merge(
            .cancel(id: WalletCancelations.AssetInitializationId()),
            .cancel(id: WalletCancelations.InitializationId()),
            .cancel(id: WalletCancelations.UpgradeId())
        )

    case .proceedToLoggedIn(.success):
        environment.loadingViewPresenter.hide()
        // prepare the context for logged in state, if required
        var context: LoggedIn.Context = .none
        if let deeplinkContent = state.onboarding?.deeplinkContent {
            context = .deeplink(deeplinkContent)
        }
        if let walletContext = state.onboarding?.walletCreationContext {
            context = .wallet(walletContext)
        }
        state.loggedIn = LoggedIn.State()
        state.onboarding = nil
        return .merge(
            .cancel(id: WalletCancelations.AssetInitializationId()),
            .cancel(id: WalletCancelations.InitializationId()),
            .cancel(id: WalletCancelations.UpgradeId()),
            Effect(value: CoreAppAction.loggedIn(.start(context))),
            Effect(value: CoreAppAction.mobileAuthSync(isLogin: true))
        )

    case .onboarding(.informForWalletInitialization):
        return Effect(value: .initializeWallet)

    case .onboarding(.welcomeScreen(.emailLogin(.verifyDevice(.credentials(.seedPhrase(.resetPassword(.reset(let password)))))))),
         .onboarding(.welcomeScreen(.restoreWallet(.resetPassword(.reset(let password))))):
        return Effect(value: .resetPassword(newPassword: password))

    case .onboarding(.walletUpgrade(.completed)):
        return Effect(
            value: CoreAppAction.prepareForLoggedIn
        )

    case .onboarding(.passwordScreen(.authenticate(let password))):
        return Effect(
            value: .fetchWallet(password: password)
        )

    case .onboarding(.pin(.handleAuthentication(let password))):
        environment.performanceTracing.begin(trace: .pinToDashboard)
        return Effect(
            value: .fetchWallet(password: password)
        )

    case .onboarding(.pin(.pinCreated)):
        return Effect(
            value: .initializeWallet
        )

    case .onboarding(.welcomeScreen(.requestedToDecryptWallet(let password))):
        return Effect(
            value: .fetchWallet(password: password)
        )

    case .onboarding(.welcomeScreen(.requestedToRestoreWallet(let walletRecovery))):
        switch walletRecovery {
        case .metadataRecovery,
             .importRecovery:
            return .none
        case .resetAccountRecovery:
            return .none
        }
    case .onboarding(.welcomeScreen(.triggerAuthenticate)):
        // this is needed for legacy wallet recovery flow
        return Effect(value: CoreAppAction.authenticate)
    case .onboarding(.welcomeScreen(.triggerCancelAuthenticate)):
        return .merge(
            .cancel(id: WalletCancelations.DecryptId()),
            .cancel(id: WalletCancelations.AuthenticationId())
        )
    case .loggedIn(.deleteWallet):

        // logout
        environment.walletManager.close()

        NotificationCenter.default.post(name: .logout, object: nil)
        environment.analyticsRecorder.record(
            event: AnalyticsEvents.New.Navigation.signedOut
        )

        environment.siftService.removeUserId()
        environment.sharedContainer.reset()
        environment.blockchainSettings.reset()

        // forget wallet
        environment.credentialsStore.erase()
        environment.walletManager.forgetWallet()

        // update state
        state.loggedIn = nil
        state.onboarding = .init(
            welcomeState: .init()
        )

        return .merge(
            environment.forgetWalletService
                .forget()
                .receive(on: environment.mainQueue)
                .catchToEffect()
                .fireAndForget(),
            environment
                .pushNotificationsRepository
                .revokeToken()
                .receive(on: environment.mainQueue)
                .catchToEffect()
                .fireAndForget(),
            environment
                .mobileAuthSyncService
                .updateMobileSetup(isMobileSetup: false)
                .receive(on: environment.mainQueue)
                .catchToEffect()
                .fireAndForget(),
            environment
                .mobileAuthSyncService
                .verifyCloudBackup(hasCloudBackup: false)
                .receive(on: environment.mainQueue)
                .catchToEffect()
                .fireAndForget()
        )
    case .onboarding(.welcomeScreen(.informWalletFetched(let context))):
        return Effect(value: .wallet(.walletFetched(.success(context))))
    case .onboarding(.pin(.logout)),
         .loggedIn(.logout):
        // reset
        environment.walletManager.close()

        NotificationCenter.default.post(name: .logout, object: nil)
        environment.analyticsRecorder.record(
            event: AnalyticsEvents.New.Navigation.signedOut
        )

        environment.siftService.removeUserId()
        environment.sharedContainer.reset()
        environment.blockchainSettings.reset()

        // update state
        state.loggedIn = nil
        state.onboarding = .init(
            pinState: nil,
            walletUpgradeState: nil,
            passwordRequiredState: .init(
                walletIdentifier: environment.blockchainSettings.guid ?? ""
            )
        )
        // show password screen
        return Effect(value: .onboarding(.passwordScreen(.start)))

    case .loggedIn(.wallet(.authenticateForBiometrics(let password))):
        return Effect(value: .fetchWallet(password: password))

    case .resetPassword(let newPassword):
        return environment
            .resetPasswordService
            .setNewPassword(newPassword: newPassword)
            .receive(on: environment.mainQueue)
            .catchToEffect()
            .map { result -> CoreAppAction in
                guard case .success = result else {
                    environment.analyticsRecorder.record(
                        event: AnalyticsEvents.New.AccountRecoveryCoreFlow.accountRecoveryFailed
                    )
                    return .none
                }
                environment.analyticsRecorder.record(
                    event: AnalyticsEvents.New.AccountRecoveryCoreFlow
                        .accountPasswordReset(hasRecoveryPhrase: true)
                )
                // proceed to setup PIN after reset password if needed
                guard environment.blockchainSettings.isPinSet else {
                    return .setupPin
                }
                return .none
            }

    case .resetVerificationStatusIfNeeded(let guidOrNil, let sharedKeyOrNil):
        guard let context = state.onboarding?.walletRecoveryContext,
              let guid = guidOrNil,
              let sharedKey = sharedKeyOrNil
        else {
            return .none
        }
        return environment
            .accountRecoveryService
            .resetVerificationStatus(guid: guid, sharedKey: sharedKey)
            .receive(on: environment.mainQueue)
            .catchToEffect()
            .map { result -> CoreAppAction in
                guard case .success = result else {
                    environment.analyticsRecorder.record(
                        event: AnalyticsEvents.New.AccountRecoveryCoreFlow.accountRecoveryFailed
                    )
                    return .none
                }
                return .none
            }

    case .mobileAuthSync(let isLogin):
        return .merge(
            environment
                .mobileAuthSyncService
                .updateMobileSetup(isMobileSetup: isLogin)
                .receive(on: environment.mainQueue)
                .eraseToEffect()
                .fireAndForget(),
            environment
                .mobileAuthSyncService
                .verifyCloudBackup(hasCloudBackup: isLogin)
                .receive(on: environment.mainQueue)
                .eraseToEffect()
                .fireAndForget()
        )

    case .onboarding,
         .loggedIn,
         .authorizeDevice,
         .none:
        return .none
    default:
        return .none
    }
}
.walletReducer()
.alertReducer()
.namespace()

// MARK: - Alert Reducer

extension Reducer where State == CoreAppState, Action == CoreAppAction, Environment == CoreAppEnvironment {
    /// Returns a combined reducer that handles all the wallet related actions
    func alertReducer() -> Self {
        combined(
            with: Reducer { state, action, environment in
                switch action {
                case .alert(.show(let title, let message, let buttons)):
                    let defaultButton = AlertState<CoreAppAction>.Button.default(
                        TextState(verbatim: LocalizationConstants.ErrorAlert.button),
                        action: .send(.alert(.dismiss))
                    )
                    let buttons = buttons ?? CoreAlertAction.Buttons(
                        primary: defaultButton,
                        secondary: nil
                    )
                    if let secondary = buttons.secondary {
                        state.alertState = AlertState(
                            title: TextState(verbatim: title),
                            message: TextState(verbatim: message),
                            primaryButton: buttons.primary,
                            secondaryButton: secondary
                        )
                    } else {
                        state.alertState = AlertState(
                            title: TextState(verbatim: title),
                            message: TextState(verbatim: message),
                            dismissButton: buttons.primary
                        )
                    }
                    return .none
                case .alert(.dismiss):
                    state.alertState = nil
                    return .none

                case .alert(.openAppStore):
                    state.alertState = nil
                    environment.appStoreOpener.openAppStore()
                    return .none
                default:
                    return .none
                }
            }
        )
    }
}

// MARK: Private Methods

/// - Note:
/// In order to login to wallet, we need to know:
/// - GUID                 - To look up the wallet
/// - SharedKey            - To be able to read/write to the wallet db record (payload, settings, etc)
/// - EncryptedPinPassword - To decrypt the wallet
/// - PinKey               - Used in conjunction with the user's PIN to retrieve decryption key to the -  EncryptedPinPassword (EncryptedWalletPassword)
/// - PIN                  - Provided by the user or retrieved from secure enclave if Face/TouchID is enabled
///
/// In this method, we backup/restore the pinKey - which is essentially the identifier of the PIN.
/// Upon successful PIN authentication, we will backup/restore the remaining wallet details: guid, sharedKey, encryptedPinPassword.
///
/// The backup/restore of guid and sharedKey requires an encryption/decryption step when backing up and restoring respectively.
///
/// The key used to encrypt/decrypt the guid and sharedKey is provided in the response to a successful PIN auth attempt.
internal func syncPinKeyWithICloud(
    blockchainSettings: BlockchainSettingsAppAPI,
    credentialsStore: CredentialsStoreAPI
) {
    guard !blockchainSettings.isPairedWithWallet else {
        // Wallet is Paired, we do not need to restore.
        // We will back up after pin authentication
        return
    }

    if blockchainSettings.pinKey == nil,
       blockchainSettings.encryptedPinPassword == nil,
       blockchainSettings.guid == nil,
       blockchainSettings.sharedKey == nil
    {

        credentialsStore.synchronize()

        // Attempt to restore the pinKey from iCloud
        if let pinData = credentialsStore.pinData() {
            blockchainSettings.pinKey = pinData.pinKey
            blockchainSettings.encryptedPinPassword = pinData.encryptedPinPassword
        }
    }
}

func handleWalletDecryption(_ decryption: WalletDecryption) -> CoreAppAction {

    //// Verify valid GUID and sharedKey
    guard let guid = decryption.guid, guid.count == 36 else {
        return .decryptionFailure(
            AuthenticationError(
                code: AuthenticationError.ErrorCode.errorDecryptingWallet,
                description: LocalizationConstants.Authentication.errorDecryptingWallet
            )
        )
    }

    guard let sharedKey = decryption.sharedKey, sharedKey.count == 36 else {
        return .decryptionFailure(
            AuthenticationError(
                code: AuthenticationError.ErrorCode.invalidSharedKey,
                description: LocalizationConstants.Authentication.invalidSharedKey
            )
        )
    }

    return .didDecryptWallet(decryption)
}

func clearPinIfNeeded(for passwordPartHash: String?, appSettings: AppSettingsAuthenticating) {
    // Because we are not storing the password on the device. We record the first few letters of the hashed password.
    // With the hash prefix we can then figure out if the password changed. If so, clear the pin
    // so that the user can reset it
    guard let passwordPartHash = passwordPartHash,
          let savedPasswordPartHash = appSettings.passwordPartHash
    else {
        return
    }

    guard passwordPartHash != savedPasswordPartHash else {
        return
    }

    appSettings.clearPin()
}

extension Reducer where Action == CoreAppAction, Environment == CoreAppEnvironment {

    func namespace() -> Reducer {
        Reducer { _, action, environment in
            switch action {
            case .fetchedUser(let result):
                guard let user = try? result.get() else { return .none }
                return .fireAndForget {
                    environment.app.signIn(userId: user.identifier)
                }
            default:
                return .none
            }
        }
        .combined(with: self)
    }
}
