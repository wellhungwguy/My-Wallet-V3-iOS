// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import AnalyticsKit
import BlockchainNamespace
import Combine
import ComposableArchitecture
import FeatureAuthenticationDomain
import FeatureSettingsDomain
import Localization
import ObservabilityKit
import PlatformKit
import PlatformUIKit
import RemoteNotificationsKit
import RxSwift
import ToolKit
import WalletPayloadKit

struct LoggedInIdentifier: Hashable {}

public enum LoggedIn {
    /// Transient context to be used as part of start method
    public enum Context: Equatable {
        case wallet(WalletCreationContext)
        case deeplink(URIContent)
        case none
    }

    public enum Action: Equatable {
        case none
        case start(LoggedIn.Context)
        case stop
        case logout
        case deleteWallet
        case deeplink(URIContent)
        case deeplinkHandled
        // wallet related actions
        case wallet(WalletAction)
        case handleNewWalletCreation
        case handleExistingWalletSignIn
        case showPostSignUpOnboardingFlow
        case didShowPostSignUpOnboardingFlow
        case showPostSignInOnboardingFlow
        case didShowPostSignInOnboardingFlow
        // symbol change actions, used by old address screen
        case symbolChanged
        case symbolChangedHandled
    }

    public struct State: Equatable {
        public var reloadAfterSymbolChanged: Bool = false
        public var reloadAfterMultiAddressResponse: Bool = false
        public var displaySendCryptoScreen: Bool = false
        public var displayPostSignUpOnboardingFlow: Bool = false
        public var displayPostSignInOnboardingFlow: Bool = false
        public var displayWalletAlertContent: AlertViewContent?
    }

    public struct Environment {
        var analyticsRecorder: AnalyticsEventRecorderAPI
        var app: AppProtocol
        var appSettings: BlockchainSettingsAppAPI
        var deeplinkRouter: DeepLinkRouting
        var exchangeRepository: ExchangeAccountRepositoryAPI
        var featureFlagsService: FeatureFlagsServiceAPI
        var fiatCurrencySettingsService: FiatCurrencySettingsServiceAPI
        var loadingViewPresenter: LoadingViewPresenting
        var mainQueue: AnySchedulerOf<DispatchQueue>
        var nabuUserService: NabuUserServiceAPI
        var performanceTracing: PerformanceTracingServiceAPI
        var remoteNotificationAuthorizer: RemoteNotificationAuthorizationRequesting
        var remoteNotificationTokenSender: RemoteNotificationTokenSending
        var walletManager: WalletManagerAPI
    }

    public enum WalletAction: Equatable {
        case authenticateForBiometrics(password: String)
        case accountInfoAndExchangeRates
        case accountInfoAndExchangeRatesHandled
        case handleWalletBackup
        case handleFailToLoadHistory(String?)
    }
}

let loggedInReducer = Reducer<
    LoggedIn.State,
    LoggedIn.Action,
    LoggedIn.Environment
> { state, action, environment in
    switch action {
    case .start(let context):
        environment.performanceTracing.end(trace: .pinToDashboard)
        return .merge(
            .run { subscriber in
                environment.appSettings.onSymbolLocalChanged = { _ in
                    subscriber.send(.symbolChanged)
                }
                return AnyCancellable {
                    environment.appSettings.onSymbolLocalChanged = nil
                }
            }
            .cancellable(id: LoggedInIdentifier()),
            environment.walletManager.walletDidGetAccountInfoAndExchangeRates
                .receive(on: environment.mainQueue)
                .catchToEffect()
                .cancellable(id: LoggedInIdentifier())
                .map { _ in LoggedIn.Action.wallet(.accountInfoAndExchangeRates) },
            environment.walletManager.walletBackupFailed
                .receive(on: environment.mainQueue)
                .catchToEffect()
                .cancellable(id: LoggedInIdentifier())
                .map { _ in LoggedIn.Action.wallet(.handleWalletBackup) },
            environment.walletManager.walletBackupSuccess
                .receive(on: environment.mainQueue)
                .catchToEffect()
                .cancellable(id: LoggedInIdentifier())
                .map { _ in LoggedIn.Action.wallet(.handleWalletBackup) },
            environment.walletManager.walletFailedToGetHistory
                .receive(on: environment.mainQueue)
                .catchToEffect()
                .cancellable(id: LoggedInIdentifier())
                .map { result in
                    guard case .success(let error) = result else {
                        return .none
                    }
                    return LoggedIn.Action.wallet(.handleFailToLoadHistory(error))
                },
            environment.exchangeRepository
                .syncDepositAddressesIfLinked()
                .receive(on: environment.mainQueue)
                .catchToEffect()
                .fireAndForget(),
            environment.remoteNotificationTokenSender
                .sendTokenIfNeeded()
                .receive(on: environment.mainQueue)
                .catchToEffect()
                .fireAndForget(),
            environment.remoteNotificationAuthorizer
                .requestAuthorizationIfNeeded()
                .receive(on: environment.mainQueue)
                .catchToEffect()
                .fireAndForget(),
            .fireAndForget {
                NotificationCenter.default.post(name: .login, object: nil)
                environment.analyticsRecorder.record(
                    event: AnalyticsEvents.New.Navigation.signedIn
                )
            },
            handleStartup(
                context: context
            )
        )
    case .deeplink(let content):
        let context = content.context
        guard context == .executeDeeplinkRouting else {
            guard context == .sendCrypto else {
                return Effect(value: .deeplinkHandled)
            }
            state.displaySendCryptoScreen = true
            return Effect(value: .deeplinkHandled)
        }
        // perform legacy routing
        environment.deeplinkRouter.routeIfNeeded()
        return .none
    case .deeplinkHandled:
        // clear up state
        state.displaySendCryptoScreen = false
        return .none
    case .handleNewWalletCreation:
        environment.app.post(event: blockchain.user.wallet.created)
        return Effect(value: .showPostSignUpOnboardingFlow)
    case .handleExistingWalletSignIn:
        return Effect(value: .showPostSignInOnboardingFlow)
    case .showPostSignUpOnboardingFlow:
        // display new onboarding flow
        state.displayPostSignUpOnboardingFlow = true
        return .none
    case .didShowPostSignUpOnboardingFlow:
        state.displayPostSignUpOnboardingFlow = false
        return .none
    case .showPostSignInOnboardingFlow:
        state.displayPostSignInOnboardingFlow = true
        return .none
    case .didShowPostSignInOnboardingFlow:
        state.displayPostSignInOnboardingFlow = false
        return .none
    case .logout:
        state = LoggedIn.State()
        return .cancel(id: LoggedInIdentifier())
    case .deleteWallet:
        return Effect(value: .logout)
    case .stop:
        // We need to cancel any running operations if we require pin entry.
        // Although this is the same as logout and .wallet(.authenticateForBiometrics)
        // I wanted to have a distinct action for this.
        return .cancel(id: LoggedInIdentifier())
    case .wallet(.authenticateForBiometrics):
        return .cancel(id: LoggedInIdentifier())
    case .wallet(.accountInfoAndExchangeRates):
        environment.loadingViewPresenter.hide()
        state.reloadAfterMultiAddressResponse = true
        return Effect(value: .wallet(.accountInfoAndExchangeRatesHandled))
    case .wallet(.accountInfoAndExchangeRatesHandled):
        state.reloadAfterMultiAddressResponse = false
        return .none
    case .wallet(.handleWalletBackup):
        environment.walletManager.walletGetHistoryForAllAssets()
        return .none
    case .wallet(.handleFailToLoadHistory(let error)):
        // the logic heres follow what was on the legacy AppCoordinator
        guard let errorMessage = error, !errorMessage.isEmpty else {
            state.displayWalletAlertContent = AlertViewContent(
                title: LocalizationConstants.Errors.error,
                message: LocalizationConstants.Errors.noInternetConnectionPleaseCheckNetwork
            )
            return .none
        }
        environment.analyticsRecorder.record(
            event: AnalyticsEvents.BTCHistoryEvent.btcHistoryError(errorMessage)
        )
        state.displayWalletAlertContent = AlertViewContent(
            title: LocalizationConstants.Errors.error,
            message: LocalizationConstants.Errors.balancesGeneric
        )
        return .none
    case .symbolChanged:
        state.reloadAfterSymbolChanged = true
        return Effect(value: .symbolChangedHandled)
    case .symbolChangedHandled:
        state.reloadAfterSymbolChanged = false
        return .none
    case .none:
        return .none
    }
}
.namespace()

// MARK: Private

/// Handle the context of a logged in state, eg wallet creation, deeplink, etc
/// - Parameter context: A `LoggedIn.Context` to be taken into account after logging in
/// - Returns: An `Effect<LoggedIn.Action, Never>` based on the context
private func handleStartup(
    context: LoggedIn.Context
) -> Effect<LoggedIn.Action, Never> {
    switch context {
    case .wallet(let walletContext) where walletContext.isNew:
        return Effect(value: .handleNewWalletCreation)
    case .wallet:
        // ignore existing/recovery wallet context
        return .none
    case .deeplink(let deeplinkContent):
        return Effect(value: .deeplink(deeplinkContent))
    case .none:
        return Effect(value: .handleExistingWalletSignIn)
    }
}

extension Reducer where Action == LoggedIn.Action, Environment == LoggedIn.Environment {

    func namespace() -> Reducer {
        Reducer { _, action, environment in
            switch action {
            case .logout:
                return .fireAndForget {
                    environment.app.signOut()
                }
            default:
                return .none
            }
        }
        .combined(with: self)
    }
}
