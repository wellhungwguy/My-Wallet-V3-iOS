//  Copyright © 2021 Blockchain Luxembourg S.A. All rights reserved.

import Combine
import ComposableArchitecture
import DIKit
import FeatureAppDomain
import FeatureAppUI
import FeatureAuthenticationDomain
import FeatureDashboardUI
import FeatureOnboardingUI
import FeatureTransactionUI
import FeatureWalletConnectDomain
import PlatformKit
import PlatformUIKit
import StoreKit
import SwiftUI
import ToolKit

final class RootViewController: UIHostingController<RootView> {

    let viewStore: ViewStore<RootViewState, RootViewAction>

    var defaults: CacheSuite = UserDefaults.standard
    var send: (LoggedIn.Action) -> Void

    var appStoreReview: AnyCancellable?
    var bag: Set<AnyCancellable> = []

    init(store global: Store<LoggedIn.State, LoggedIn.Action>) {

        send = ViewStore(global).send

        let environment = RootViewEnvironment(
            app: app
        )
        let store = Store(
            initialState: RootViewState(
                fab: .init(
                    animate: !defaults.hasInteractedWithFrequentActionButton
                ),
                referralState: .init(
                    isHighlighted: false,
                    referral: nil
                )
            ),
            reducer: rootViewReducer,
            environment: environment
        )

        viewStore = ViewStore(store)

        super.init(rootView: RootView(store: store))

        subscribe(to: viewStore)
        subscribe(to: ViewStore(global))

        if !defaults.hasInteractedWithFrequentActionButton {
            environment.publisher
                .map(\.state.fab.isOn)
                .first(where: \.self)
                .sink(to: My.handleFirstFrequentActionButtonInteraction, on: self)
                .store(in: &bag)
        }

        environment.publisher
            .sink(to: My.handle(state:action:), on: self)
            .store(in: &bag)
    }

    @objc dynamic required init?(coder aDecoder: NSCoder) {
        unimplemented()
    }

    func clear() {
        bag.removeAll()
    }

    // MARK: Dependencies

    @LazyInject var alertViewPresenter: AlertViewPresenterAPI
    @LazyInject var backupRouter: FeatureDashboardUI.BackupRouterAPI
    @LazyInject var coincore: CoincoreAPI
    @LazyInject var eligibilityService: EligibilityServiceAPI
    @LazyInject var featureFlagService: FeatureFlagsServiceAPI
    @LazyInject var fiatCurrencyService: FiatCurrencyServiceAPI
    @LazyInject var kycRouter: PlatformUIKit.KYCRouting
    @LazyInject var onboardingRouter: FeatureOnboardingUI.OnboardingRouterAPI
    @LazyInject var tiersService: KYCTiersServiceAPI
    @LazyInject var transactionsRouter: FeatureTransactionUI.TransactionsRouterAPI
    @Inject var walletConnectService: WalletConnectServiceAPI
    @Inject var walletConnectRouter: WalletConnectRouterAPI

    var pinRouter: PinRouter?
    weak var accountsAndAddressesNavigationController: AccountsAndAddressesNavigationController?

    lazy var bottomSheetPresenter = BottomSheetPresenting()
}

extension RootViewController {

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        appStoreReview = NotificationCenter.default.publisher(for: .transaction)
            .first()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                guard let scene = self?.view.window?.windowScene else { return }
                #if INTERNAL_BUILD
                scene.peek("🧾 Show App Store Review Prompt!")
                #else
                SKStoreReviewController.requestReview(in: scene)
                #endif
            }
    }
}

extension RootViewController {

    func subscribe(to viewStore: ViewStore<RootViewState, RootViewAction>) {
        viewStore.publisher.tab.sink { [weak self] _ in
            self?.presentedViewController?.dismiss(animated: true)
        }
        .store(in: &bag)
    }

    func subscribe(to viewStore: ViewStore<LoggedIn.State, LoggedIn.Action>) {

        viewStore.publisher
            .reloadAfterMultiAddressResponse
            .filter { $0 }
            .sink(to: My.reload, on: self)
            .store(in: &bag)

        viewStore.publisher
            .reloadAfterSymbolChanged
            .filter { $0 }
            .sink(to: My.reload, on: self)
            .store(in: &bag)

        viewStore.publisher
            .displayWalletAlertContent
            .compactMap { $0 }
            .removeDuplicates()
            .sink(to: My.alert, on: self)
            .store(in: &bag)

        viewStore.publisher
            .displaySendCryptoScreen
            .filter(\.self)
            .sink(to: My.handleSendCrypto, on: self)
            .store(in: &bag)

        viewStore.publisher
            .displayPostSignUpOnboardingFlow
            .filter(\.self)
            .handleEvents(receiveOutput: { _ in
                // reset onboarding state
                viewStore.send(.didShowPostSignUpOnboardingFlow)
            })
            .sink(to: My.presentPostSignUpOnboarding, on: self)
            .store(in: &bag)

        viewStore.publisher
            .displayPostSignInOnboardingFlow
            .filter(\.self)
            .handleEvents(receiveOutput: { _ in
                // reset onboarding state
                viewStore.send(.didShowPostSignInOnboardingFlow)
            })
            .sink(to: My.presentPostSignInOnboarding, on: self)
            .store(in: &bag)
    }
}

extension RootViewController {

    func handleFirstFrequentActionButtonInteraction() {
        defaults.hasInteractedWithFrequentActionButton = true
    }

    // swiftlint:disable cyclomatic_complexity
    func handle(state: RootViewState, action: RootViewAction) {
        switch action {
        case .frequentAction(let frequentAction):
            switch frequentAction.tag {
            case blockchain.ux.frequent.action.swap:
                handleSwapCrypto(account: nil)
            case blockchain.ux.frequent.action.send:
                handleSendCrypto()
            case blockchain.ux.frequent.action.receive:
                handleReceiveCrypto()
            case blockchain.ux.frequent.action.rewards:
                handleRewards()
            case blockchain.ux.frequent.action.deposit:
                handleDeposit()
            case blockchain.ux.frequent.action.withdraw:
                handleWithdraw()
            case blockchain.ux.frequent.action.buy:
                handleBuyCrypto(currency: .bitcoin)
            case blockchain.ux.frequent.action.sell:
                handleSellCrypto(account: nil)
            default:
                assertionFailure("Unhandled action \(action)")
            }
        default:
            break
        }
    }
}

extension CacheSuite {

    var hasInteractedWithFrequentActionButton: Bool {
        get { bool(forKey: #function) }
        set { set(newValue, forKey: #function) }
    }
}
