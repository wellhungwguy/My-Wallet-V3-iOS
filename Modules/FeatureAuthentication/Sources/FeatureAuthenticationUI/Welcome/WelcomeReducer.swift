// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import AnalyticsKit
import BlockchainNamespace
import Combine
import ComposableArchitecture
import ComposableNavigation
import DIKit
import FeatureAuthenticationDomain
import ToolKit
import WalletPayloadKit

// MARK: - Type

public enum WelcomeAction: Equatable, NavigationAction {

    // MARK: - Start Up

    case start

    // MARK: - Deep link

    case deeplinkReceived(URL)

    // MARK: - Wallet

    case requestedToCreateWallet(String, String)
    case requestedToDecryptWallet(String)
    case requestedToRestoreWallet(WalletRecovery)

    // MARK: - Navigation

    case route(RouteIntent<WelcomeRoute>?)

    // MARK: - Local Action

    case createWallet(CreateAccountAction)
    case emailLogin(EmailLoginAction)
    case restoreWallet(SeedPhraseAction)
    case setManualPairingEnabled // should only be on internal build
    case manualPairing(CredentialsAction) // should only be on internal build
    case informSecondPasswordDetected
    case informForWalletInitialization
    case informWalletFetched(WalletFetchedContext)

    case triggerAuthenticate // needed for legacy wallet flow
    case triggerCancelAuthenticate // needed for legacy wallet flow

    // MARK: - Utils

    case none
}

// MARK: - Properties

/// The `master` `State` for the Single Sign On (SSO) Flow
public struct WelcomeState: Equatable, NavigationState {
    public var buildVersion: String
    public var route: RouteIntent<WelcomeRoute>?
    public var createWalletState: CreateAccountState?
    public var emailLoginState: EmailLoginState?
    public var restoreWalletState: SeedPhraseState?
    public var manualPairingEnabled: Bool
    public var manualCredentialsState: CredentialsState?

    public init() {
        buildVersion = ""
        route = nil
        createWalletState = nil
        restoreWalletState = nil
        emailLoginState = nil
        manualPairingEnabled = false
        manualCredentialsState = nil
    }
}

public struct WelcomeEnvironment {
    let app: AppProtocol
    let mainQueue: AnySchedulerOf<DispatchQueue>
    let passwordValidator: PasswordValidatorAPI
    let sessionTokenService: SessionTokenServiceAPI
    let deviceVerificationService: DeviceVerificationServiceAPI
    let buildVersionProvider: () -> String
    let featureFlagsService: FeatureFlagsServiceAPI
    let errorRecorder: ErrorRecording
    let externalAppOpener: ExternalAppOpener
    let analyticsRecorder: AnalyticsEventRecorderAPI
    let walletRecoveryService: WalletRecoveryService
    let walletCreationService: WalletCreationService
    let walletFetcherService: WalletFetcherService
    let accountRecoveryService: AccountRecoveryServiceAPI
    let checkReferralClient: CheckReferralClientAPI
    let nativeWalletEnabled: () -> AnyPublisher<Bool, Never>

    public init(
        app: AppProtocol,
        mainQueue: AnySchedulerOf<DispatchQueue>,
        passwordValidator: PasswordValidatorAPI = resolve(),
        sessionTokenService: SessionTokenServiceAPI = resolve(),
        deviceVerificationService: DeviceVerificationServiceAPI,
        featureFlagsService: FeatureFlagsServiceAPI,
        buildVersionProvider: @escaping () -> String,
        errorRecorder: ErrorRecording = resolve(),
        externalAppOpener: ExternalAppOpener = resolve(),
        analyticsRecorder: AnalyticsEventRecorderAPI = resolve(),
        walletRecoveryService: WalletRecoveryService = DIKit.resolve(),
        walletCreationService: WalletCreationService = DIKit.resolve(),
        walletFetcherService: WalletFetcherService = DIKit.resolve(),
        accountRecoveryService: AccountRecoveryServiceAPI = DIKit.resolve(),
        checkReferralClient: CheckReferralClientAPI = DIKit.resolve(),
        nativeWalletEnabled: @escaping () -> AnyPublisher<Bool, Never>
    ) {
        self.app = app
        self.mainQueue = mainQueue
        self.passwordValidator = passwordValidator
        self.sessionTokenService = sessionTokenService
        self.deviceVerificationService = deviceVerificationService
        self.buildVersionProvider = buildVersionProvider
        self.featureFlagsService = featureFlagsService
        self.errorRecorder = errorRecorder
        self.externalAppOpener = externalAppOpener
        self.analyticsRecorder = analyticsRecorder
        self.walletRecoveryService = walletRecoveryService
        self.walletCreationService = walletCreationService
        self.walletFetcherService = walletFetcherService
        self.accountRecoveryService = accountRecoveryService
        self.checkReferralClient = checkReferralClient
        self.nativeWalletEnabled = nativeWalletEnabled
    }
}

public let welcomeReducer = Reducer.combine(
    createAccountReducer
        .optional()
        .pullback(
            state: \.createWalletState,
            action: /WelcomeAction.createWallet,
            environment: {
                CreateAccountEnvironment(
                    mainQueue: $0.mainQueue,
                    passwordValidator: $0.passwordValidator,
                    externalAppOpener: $0.externalAppOpener,
                    analyticsRecorder: $0.analyticsRecorder,
                    walletRecoveryService: $0.walletRecoveryService,
                    walletCreationService: $0.walletCreationService,
                    walletFetcherService: $0.walletFetcherService,
                    featureFlagsService: $0.featureFlagsService,
                    checkReferralClient: $0.checkReferralClient,
                    app: $0.app
                )
            }
        ),
    emailLoginReducer
        .optional()
        .pullback(
            state: \.emailLoginState,
            action: /WelcomeAction.emailLogin,
            environment: {
                EmailLoginEnvironment(
                    app: $0.app,
                    mainQueue: $0.mainQueue,
                    sessionTokenService: $0.sessionTokenService,
                    deviceVerificationService: $0.deviceVerificationService,
                    featureFlagsService: $0.featureFlagsService,
                    errorRecorder: $0.errorRecorder,
                    externalAppOpener: $0.externalAppOpener,
                    analyticsRecorder: $0.analyticsRecorder,
                    walletRecoveryService: $0.walletRecoveryService,
                    walletCreationService: $0.walletCreationService,
                    walletFetcherService: $0.walletFetcherService,
                    accountRecoveryService: $0.accountRecoveryService
                )
            }
        ),
    seedPhraseReducer
        .optional()
        .pullback(
            state: \.restoreWalletState,
            action: /WelcomeAction.restoreWallet,
            environment: {
                SeedPhraseEnvironment(
                    mainQueue: $0.mainQueue,
                    externalAppOpener: $0.externalAppOpener,
                    analyticsRecorder: $0.analyticsRecorder,
                    walletRecoveryService: $0.walletRecoveryService,
                    walletCreationService: $0.walletCreationService,
                    walletFetcherService: $0.walletFetcherService,
                    accountRecoveryService: $0.accountRecoveryService,
                    errorRecorder: $0.errorRecorder,
                    featureFlagsService: $0.featureFlagsService
                )
            }
        ),
    credentialsReducer
        .optional()
        .pullback(
            state: \.manualCredentialsState,
            action: /WelcomeAction.manualPairing,
            environment: {
                CredentialsEnvironment(
                    mainQueue: $0.mainQueue,
                    deviceVerificationService: $0.deviceVerificationService,
                    errorRecorder: $0.errorRecorder,
                    featureFlagsService: $0.featureFlagsService,
                    analyticsRecorder: $0.analyticsRecorder,
                    walletRecoveryService: $0.walletRecoveryService,
                    walletCreationService: $0.walletCreationService,
                    walletFetcherService: $0.walletFetcherService,
                    accountRecoveryService: $0.accountRecoveryService
                )
            }
        ),
    Reducer<
        WelcomeState,
        WelcomeAction,
        WelcomeEnvironment
            // swiftlint:disable closure_body_length
    > { state, action, environment in
        switch action {
        case .route(let route):
            guard let routeValue = route?.route else {
                state.createWalletState = nil
                state.emailLoginState = nil
                state.restoreWalletState = nil
                state.manualCredentialsState = nil
                state.route = route
                return .none
            }
            switch routeValue {
            case .createWallet:
                state.createWalletState = .init(context: .createWallet)
            case .emailLogin:
                state.emailLoginState = .init()
            case .restoreWallet:
                state.restoreWalletState = .init(context: .restoreWallet)
            case .manualLogin:
                state.manualCredentialsState = .init()
            }
            state.route = route
            return .none

        case .start:
            state.buildVersion = environment.buildVersionProvider()
            if BuildFlag.isInternal {
                return environment.app
                    .publisher(for: blockchain.app.configuration.manual.login.is.enabled, as: Bool.self)
                    .prefix(1)
                    .replaceError(with: false)
                    .flatMap { isEnabled -> Effect<WelcomeAction, Never> in
                        guard isEnabled else {
                            return .none
                        }
                        return Effect(value: .setManualPairingEnabled)
                    }
                    .eraseToEffect()
            }
            return .none

        case .setManualPairingEnabled:
            state.manualPairingEnabled = true
            return .none

        case .deeplinkReceived(let url):
            // handle deeplink if we've entered verify device flow
            guard let loginState = state.emailLoginState,
                  loginState.verifyDeviceState != nil
            else {
                return .none
            }
            return Effect(value: .emailLogin(.verifyDevice(.didReceiveWalletInfoDeeplink(url))))

        case .requestedToCreateWallet,
             .requestedToDecryptWallet,
             .requestedToRestoreWallet:
            // handled in core coordinator
            return .none

        case .createWallet(.triggerAuthenticate):
            return Effect(value: .triggerAuthenticate)

        case .createWallet(.informWalletFetched(let context)):
            return Effect(value: .informWalletFetched(context))

        case .emailLogin(.verifyDevice(.credentials(.seedPhrase(.informWalletFetched(let context))))):
            return Effect(value: .informWalletFetched(context))

        // TODO: refactor this by not relying on access lower level reducers
        case .emailLogin(.verifyDevice(.credentials(.walletPairing(.decryptWalletWithPassword(let password))))),
             .emailLogin(.verifyDevice(.upgradeAccount(.skipUpgrade(.credentials(.walletPairing(.decryptWalletWithPassword(let password))))))):
            return Effect(value: .requestedToDecryptWallet(password))

        case .emailLogin(.verifyDevice(.credentials(.seedPhrase(.restoreWallet(let walletRecovery))))):
            return Effect(value: .requestedToRestoreWallet(walletRecovery))

        case .restoreWallet(.restoreWallet(let walletRecovery)):
            return Effect(value: .requestedToRestoreWallet(walletRecovery))

        case .restoreWallet(.importWallet(.createAccount(.importAccount))):
            return Effect(value: .requestedToRestoreWallet(.importRecovery))

        case .manualPairing(.walletPairing(.decryptWalletWithPassword(let password))):
            return Effect(value: .requestedToDecryptWallet(password))

        case .emailLogin(.verifyDevice(.credentials(.secondPasswordNotice(.returnTapped)))),
             .manualPairing(.secondPasswordNotice(.returnTapped)):
            return .dismiss()

        case .manualPairing(.seedPhrase(.informWalletFetched(let context))):
            return Effect(value: .informWalletFetched(context))

        case .manualPairing(.seedPhrase(.importWallet(.createAccount(.walletFetched(.success(.right(let context))))))):
            return Effect(value: .informWalletFetched(context))

        case .manualPairing:
            return .none

        case .restoreWallet(.triggerAuthenticate):
            return Effect(value: .triggerAuthenticate)

        case .emailLogin(.verifyDevice(.credentials(.seedPhrase(.triggerAuthenticate)))):
            return Effect(value: .triggerAuthenticate)

        case .restoreWallet(.restored(.success(.right(let context)))),
             .emailLogin(.verifyDevice(.credentials(.seedPhrase(.restored(.success(.right(let context))))))):
            return Effect(value: .informWalletFetched(context))

        case .restoreWallet(.importWallet(.createAccount(.walletFetched(.success(.right(let context)))))):
            return Effect(value: .informWalletFetched(context))

        case .restoreWallet(.restored(.success(.left(.noValue)))),
             .emailLogin(.verifyDevice(.credentials(.seedPhrase(.restored(.success(.left(.noValue))))))):
            return environment.nativeWalletEnabled()
                .eraseToEffect()
                .map { isEnabled -> WelcomeAction in
                    guard isEnabled else {
                        return .none
                    }
                    return .informForWalletInitialization
                }
        case .restoreWallet(.restored(.failure)),
             .emailLogin(.verifyDevice(.credentials(.seedPhrase(.restored(.failure))))):
            return Effect(value: .triggerCancelAuthenticate)
        case .createWallet(.accountCreation(.failure)):
            return Effect(value: .triggerCancelAuthenticate)

        case .informSecondPasswordDetected:
            switch state.route?.route {
            case .emailLogin:
                return Effect(value: .emailLogin(.verifyDevice(.credentials(.navigate(to: .secondPasswordDetected)))))
            case .manualLogin:
                return Effect(value: .manualPairing(.navigate(to: .secondPasswordDetected)))
            case .restoreWallet:
                return Effect(value: .restoreWallet(.setSecondPasswordNoticeVisible(true)))
            default:
                return .none
            }

        case .triggerAuthenticate,
             .triggerCancelAuthenticate,
             .informForWalletInitialization,
             .informWalletFetched:
            // handled in core coordinator
            return .none

        case .createWallet,
             .emailLogin,
             .restoreWallet:
            return .none

        case .none:
            return .none
        }
    }
)
.analytics()

extension Reducer where
    Action == WelcomeAction,
    State == WelcomeState,
    Environment == WelcomeEnvironment
{
    func analytics() -> Self {
        combined(
            with: Reducer<
                WelcomeState,
                WelcomeAction,
                WelcomeEnvironment
            > { _, action, environment in
                switch action {
                case .route(let route):
                    guard let routeValue = route?.route else {
                        return .none
                    }
                    switch routeValue {
                    case .emailLogin:
                        environment.analyticsRecorder.record(
                            event: .loginClicked()
                        )
                    case .restoreWallet:
                        environment.analyticsRecorder.record(
                            event: .recoveryOptionSelected
                        )
                    default:
                        break
                    }
                    return .none
                default:
                    return .none
                }
            }
        )
    }
}
