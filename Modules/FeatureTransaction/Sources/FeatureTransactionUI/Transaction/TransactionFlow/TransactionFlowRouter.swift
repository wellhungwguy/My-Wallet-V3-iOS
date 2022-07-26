// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import AnalyticsKit
import BlockchainComponentLibrary
import Combine
import ComposableArchitecture
import DIKit
import Errors
import ErrorsUI
import FeatureCardPaymentDomain
import FeatureOpenBankingUI
import FeatureTransactionDomain
import Localization
import PlatformKit
import PlatformUIKit
import RIBs
import SwiftUI
import ToolKit
import UIComponentsKit

protocol TransactionFlowInteractable: Interactable,
    EnterAmountPageListener,
    ConfirmationPageListener,
    AccountPickerListener,
    PendingTransactionPageListener,
    TargetSelectionPageListener
{

    var router: TransactionFlowRouting? { get set }
    var listener: TransactionFlowListener? { get set }

    func didSelectSourceAccount(account: BlockchainAccount)
    func didSelectDestinationAccount(target: TransactionTarget)
}

public protocol TransactionFlowViewControllable: ViewControllable {

    var viewControllers: [UIViewController] { get }

    func present(viewController: ViewControllable?, animated: Bool)
    func replaceRoot(viewController: ViewControllable?, animated: Bool)
    func push(viewController: ViewControllable?)
    func dismiss()
    func pop()
    func popToRoot()
    func setViewControllers(_ viewControllers: [UIViewController], animated: Bool)
}

typealias TransactionViewableRouter = ViewableRouter<TransactionFlowInteractable, TransactionFlowViewControllable>
typealias TransactionFlowAnalyticsEvent = AnalyticsEvents.New.TransactionFlow

// swiftlint:disable type_body_length
final class TransactionFlowRouter: TransactionViewableRouter, TransactionFlowRouting {

    private var app: AppProtocol
    private var paymentMethodLinker: PaymentMethodLinkingSelectorAPI
    private var bankWireLinker: BankWireLinkerAPI
    private var cardLinker: CardLinkerAPI
    private let alertViewPresenter: AlertViewPresenterAPI
    private let topMostViewControllerProvider: TopMostViewControllerProviding

    private var linkBankFlowRouter: LinkBankFlowStarter?
    private var securityRouter: PaymentSecurityRouter?
    private let kycRouter: PlatformUIKit.KYCRouting
    private let transactionsRouter: TransactionsRouterAPI
    private let cacheSuite: CacheSuite
    private let featureFlagsService: FeatureFlagsServiceAPI
    private let analyticsRecorder: AnalyticsEventRecorderAPI

    private let bottomSheetPresenter = BottomSheetPresenting(ignoresBackgroundTouches: true)

    private var cancellables = Set<AnyCancellable>()

    var isDisplayingRootViewController: Bool {
        viewController.uiviewController.presentedViewController == nil
    }

    init(
        app: AppProtocol = resolve(),
        interactor: TransactionFlowInteractable,
        viewController: TransactionFlowViewControllable,
        paymentMethodLinker: PaymentMethodLinkingSelectorAPI = resolve(),
        bankWireLinker: BankWireLinkerAPI = resolve(),
        cardLinker: CardLinkerAPI = resolve(),
        kycRouter: PlatformUIKit.KYCRouting = resolve(),
        transactionsRouter: TransactionsRouterAPI = resolve(),
        topMostViewControllerProvider: TopMostViewControllerProviding = resolve(),
        alertViewPresenter: AlertViewPresenterAPI = resolve(),
        featureFlagsService: FeatureFlagsServiceAPI = resolve(),
        analyticsRecorder: AnalyticsEventRecorderAPI = resolve(),
        cacheSuite: CacheSuite = resolve()
    ) {
        self.app = app
        self.paymentMethodLinker = paymentMethodLinker
        self.bankWireLinker = bankWireLinker
        self.cardLinker = cardLinker
        self.kycRouter = kycRouter
        self.transactionsRouter = transactionsRouter
        self.topMostViewControllerProvider = topMostViewControllerProvider
        self.alertViewPresenter = alertViewPresenter
        self.featureFlagsService = featureFlagsService
        self.analyticsRecorder = analyticsRecorder
        self.cacheSuite = cacheSuite
        super.init(interactor: interactor, viewController: viewController)
        interactor.router = self
    }

    func routeToConfirmation(transactionModel: TransactionModel) {
        let ref = blockchain.app.configuration.redesign.checkout.is.enabled
        let isEnabled = try? app.remoteConfiguration.get(ref) as? Bool

        if isEnabled ?? false {
            viewController.push(
                viewController: UIHostingController<ConfirmationView>(
                    rootView: ConfirmationView(
                        store: Store<ConfirmationState, ConfirmationAction>(
                            initialState: ConfirmationState(),
                            reducer: confirmationReducer,
                            environment: ConfirmationEnvironment()
                        )
                    )
                )
            )
        } else {
            let builder = ConfirmationPageBuilder(transactionModel: transactionModel)
            let router = builder.build(listener: interactor)
            let viewControllable = router.viewControllable
            attachChild(router)
            viewController.push(viewController: viewControllable)
        }
    }

    func routeToInProgress(transactionModel: TransactionModel, action: AssetAction) {
        let builder = PendingTransactionPageBuilder()
        let router = builder.build(
            withListener: interactor,
            transactionModel: transactionModel,
            action: action
        )
        let viewControllable = router.viewControllable
        attachChild(router)
        viewController.push(viewController: viewControllable)
    }

    func routeToError(state: TransactionState, model: TransactionModel) {
        let error = state.errorState.ux(action: state.action)
        let errorViewController = UIHostingController(
            rootView: ErrorView(
                ux: error,
                fallback: {
                    if let destination = state.destination {
                        destination.currencyType.logoResource.view
                    } else if let source = state.source {
                        source.currencyType.logoResource.view
                    } else {
                        Icon.error.foregroundColor(.semantic.warning)
                    }
                },
                dismiss: { [weak self] in
                    guard let self = self else { return }
                    self.closeFlow()
                }
            )
            .app(app)
        )

        attachChild(Router<Interactor>(interactor: Interactor()))

        if state.stepsBackStack.isNotEmpty {
            viewController.push(viewController: errorViewController)
        } else {
            viewController.replaceRoot(
                viewController: errorViewController,
                animated: false
            )
        }
    }

    func closeFlow() {
        viewController.dismiss()
        interactor.listener?.dismissTransactionFlow()
    }

    func showErrorRecoverySuggestion(
        action: AssetAction,
        errorState: TransactionErrorState,
        transactionModel: TransactionModel,
        handleCalloutTapped: @escaping (ErrorRecoveryState.Callout) -> Void
    ) {
        guard errorState != .none else {
            // The transaction is valid, there's no error to show.
            if BuildFlag.isInternal {
                fatalError("Developer error: calling `showErrorRecoverySuggestion` with an `errorState` of `none`.")
            }
            return
        }

        presentErrorRecoveryCallout(
            title: errorState.recoveryWarningTitle(for: action).or(Localization.Error.unknownError),
            message: errorState.recoveryWarningMessage(for: action),
            callouts: errorState.recoveryWarningCallouts(for: action),
            onClose: { [transactionModel] in
                transactionModel.process(action: .returnToPreviousStep)
            },
            onCalloutTapped: handleCalloutTapped
        )
    }

    func showVerifyToUnlockMoreTransactionsPrompt(action: AssetAction) {
        presentErrorRecoveryCallout(
            title: LocalizationConstants.Transaction.Notices.verifyToUnlockMoreTradingNoticeTitle,
            message: LocalizationConstants.Transaction.Notices.verifyToUnlockMoreTradingNoticeMessage,
            callouts: [
                .init(
                    image: Image("icon-verified", bundle: .main),
                    title: LocalizationConstants.Transaction.Notices.verifyToUnlockMoreTradingNoticeCalloutTitle,
                    message: LocalizationConstants.Transaction.Notices.verifyToUnlockMoreTradingNoticeCalloutMessage,
                    callToAction: LocalizationConstants.Transaction.Notices.verifyToUnlockMoreTradingNoticeCalloutCTA
                )
            ],
            onClose: { [analyticsRecorder, presenter = topMostViewControllerProvider.topMostViewController] in
                if let flowStep = TransactionFlowAnalyticsEvent.FlowStep(action) {
                    analyticsRecorder.record(
                        event: TransactionFlowAnalyticsEvent.getMoreAccessWhenYouVerifyDismissed(flowStep: flowStep)
                    )
                }
                presenter?.dismiss(animated: true)
            },
            onCalloutTapped: { [analyticsRecorder, presentKYCUpgradeFlow] _ in
                if let flowStep = TransactionFlowAnalyticsEvent.FlowStep(action) {
                    analyticsRecorder.record(
                        event: TransactionFlowAnalyticsEvent.getMoreAccessWhenYouVerifyClicked(flowStep: flowStep)
                    )
                }
                presentKYCUpgradeFlow { _ in }
            }
        )
    }

    private func presentErrorRecoveryCallout(
        title: String,
        message: String,
        callouts: [ErrorRecoveryState.Callout],
        onClose: @escaping () -> Void,
        onCalloutTapped: @escaping (ErrorRecoveryState.Callout) -> Void
    ) {
        let view = ErrorRecoveryView(
            store: .init(
                initialState: ErrorRecoveryState(title: title, message: message, callouts: callouts),
                reducer: errorRecoveryReducer,
                environment: ErrorRecoveryEnvironment(close: onClose, calloutTapped: onCalloutTapped)
            )
        )
        let viewController = UIHostingController(rootView: view)
        viewController.transitioningDelegate = bottomSheetPresenter
        viewController.modalPresentationStyle = .custom
        let presenter = topMostViewControllerProvider.topMostViewController
        presenter?.present(viewController, animated: true, completion: nil)
    }

    func pop() {
        viewController.pop()
    }

    func dismiss() {
        guard let topVC = topMostViewControllerProvider.topMostViewController else {
            return
        }
        let topRouter = children.last
        topVC.presentingViewController?.dismiss(animated: true) { [weak self] in
            // Detatch child in completion block to avoid false-positive leak checks
            guard let child = topRouter as? ViewableRouting, child.viewControllable.uiviewController === topVC else {
                return
            }
            self?.detachChild(child)
        }
    }

    func didTapBack() {
        guard let child = children.last else { return }
        pop()
        detachChild(child)
    }

    func pop<T: UIViewController>(to type: T.Type) {
        var viewable = children
        for child in Array(viewable.reversed()) {
            guard let child = child as? ViewableRouting else { continue }
            viewable = viewable.dropLast()
            if child.viewControllable.uiviewController is T { break }
            detachChild(child as Routing)
        }
        children = viewable as [Routing]
        let viewControllers = viewable.filter(ViewableRouting.self).map(\.viewControllable.uiviewController)
        viewController.setViewControllers(viewControllers, animated: true)
    }

    func routeToSourceAccountPicker(
        transitionType: TransitionType,
        transactionModel: TransactionModel,
        action: AssetAction,
        canAddMoreSources: Bool
    ) {
        let router = sourceAccountPickerRouter(
            with: transactionModel,
            action: action,
            canAddMoreSources: canAddMoreSources
        )
        attachAndPresent(router, transitionType: transitionType)
    }

    func routeToDestinationAccountPicker(
        transitionType: TransitionType,
        transactionModel: TransactionModel,
        action: AssetAction
    ) {
        let navigationModel: ScreenNavigationModel
        switch transitionType {
        case .push:
            navigationModel = ScreenNavigationModel.AccountPicker.navigationClose(
                title: TransactionFlowDescriptor.AccountPicker.destinationTitle(action: action)
            )
        case .modal, .replaceRoot:
            navigationModel = ScreenNavigationModel.AccountPicker.modal(
                title: TransactionFlowDescriptor.AccountPicker.destinationTitle(action: action)
            )
        }
        let router = destinationAccountPicker(
            with: transactionModel,
            navigationModel: navigationModel,
            action: action
        )
        attachAndPresent(router, transitionType: transitionType)
    }

    func routeToTargetSelectionPicker(transactionModel: TransactionModel, action: AssetAction) {
        let builder = TargetSelectionPageBuilder(
            accountProvider: TransactionModelAccountProvider(
                transactionModel: transactionModel,
                transform: { $0.availableTargets as? [BlockchainAccount] ?? [] }
            ),
            action: action,
            cacheSuite: cacheSuite,
            featureFlagsService: featureFlagsService
        )
        let router = builder.build(
            listener: .listener(interactor),
            navigationModel: ScreenNavigationModel.TargetSelection.navigation(
                title: TransactionFlowDescriptor.TargetSelection.navigationTitle(action: action)
            ),
            backButtonInterceptor: {
                transactionModel.state.map {
                    ($0.step, $0.stepsBackStack, $0.isGoingBack)
                }
            }
        )
        attachAndPresent(router, transitionType: .replaceRoot)
    }

    func presentLinkPaymentMethod(transactionModel: TransactionModel) {
        let viewController = viewController.uiviewController
        let presenter = viewController.topMostViewController ?? viewController
        paymentMethodLinker.presentAccountLinkingFlow(from: presenter) { [weak self] result in
            guard let self = self else { return }
            viewController.dismiss(animated: true) {
                switch result {
                case .abandoned:
                    transactionModel.process(action: .returnToPreviousStep)
                case .completed(let paymentMethod):
                    switch paymentMethod.type {
                    case .applePay:
                        transactionModel.process(
                            action: .sourceAccountSelected(PaymentMethodAccount.applePay(from: paymentMethod))
                        )
                    case .bankAccount:
                        transactionModel.process(action: .showBankWiringInstructions)
                    case .bankTransfer:
                        switch paymentMethod.fiatCurrency {
                        case .USD:
                            transactionModel.process(action: .showBankLinkingFlow)
                        case .GBP, .EUR:
                            self.featureFlagsService
                                .isEnabled(.openBanking)
                                .if(
                                    then: {
                                        transactionModel.process(action: .showBankLinkingFlow)
                                    },
                                    else: {
                                        transactionModel.process(action: .showBankWiringInstructions)
                                    }
                                )
                                .store(in: &self.cancellables)
                        default:
                            transactionModel.process(action: .showBankWiringInstructions)
                        }
                    case .card:
                        transactionModel.process(action: .showCardLinkingFlow)
                    case .funds:
                        transactionModel.process(action: .showBankWiringInstructions)
                    }
                }
            }
        }
    }

    func presentLinkACard(transactionModel: TransactionModel) {
        let presenter = viewController.uiviewController.topMostViewController ?? viewController.uiviewController
        cardLinker.presentCardLinkingFlow(from: presenter) { [transactionModel] result in
            presenter.dismiss(animated: true) {
                switch result {
                case .abandoned:
                    transactionModel.process(action: .returnToPreviousStep)
                case .completed(let data):
                    transactionModel.process(action: .cardLinkingFlowCompleted(data))
                }
            }
        }
    }

    func presentLinkABank(transactionModel: TransactionModel) {
        let builder = LinkBankFlowRootBuilder()
        let router = builder.build()
        linkBankFlowRouter = router
        analyticsRecorder.record(event: AnalyticsEvents.New.SimpleBuy.linkBankClicked(origin: .buy))
        router.startFlow()
            .withLatestFrom(transactionModel.state) { ($0, $1) }
            .asPublisher()
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [topMostViewControllerProvider] effect, state in
                topMostViewControllerProvider
                    .topMostViewController?
                    .dismiss(animated: true, completion: nil)
                switch effect {
                case .closeFlow:
                    transactionModel.process(action: .bankLinkingFlowDismissed(state.action))
                case .bankLinked:
                    transactionModel.process(action: .bankAccountLinked(state.action))
                }
            })
            .store(in: &cancellables)
    }

    func presentBankWiringInstructions(transactionModel: TransactionModel) {
        let presenter = viewController.uiviewController.topMostViewController ?? viewController.uiviewController
        // NOTE: using [weak presenter] to avoid a memory leak
        bankWireLinker.presentBankWireInstructions(from: presenter) { [weak presenter] in
            presenter?.dismiss(animated: true) {
                transactionModel.process(action: .returnToPreviousStep)
            }
        }
    }

    func presentOpenBanking(
        action: OpenBankingAction,
        transactionModel: TransactionModel,
        account: LinkedBankData
    ) {

        let presentingViewController = viewController.uiviewController.topMostViewController
            ?? viewController.uiviewController

        guard let presenter = presentingViewController as? TransactionFlowViewControllable else {
            fatalError(
                """
                Unable to present OpenBanking
                expected TransactionFlowViewControllable but got \(type(of: presentingViewController))
                """
            )
        }

        let environment = OpenBankingEnvironment(
            app: resolve(),
            dismiss: { [weak presenter] in
                presenter?.dismiss()
            },
            cancel: { [weak presenter] in
                presenter?.popToRoot()
            },
            currency: action.currency
        )

        let viewController: OpenBankingViewController
        switch action {
        case .buy(let order):
            viewController = OpenBankingViewController(
                order: .init(order),
                from: .init(account),
                environment: environment
            )
        case .deposit(let transaction):
            viewController = OpenBankingViewController(
                deposit: transaction.amount.minorString,
                product: "SIMPLEBUY",
                from: .init(account),
                environment: environment
            )
        }

        viewController.eventPublisher.sink { [weak presenter] result in
            switch result {
            case .success:
                transactionModel.process(action: .updateTransactionComplete)
                presenter?.dismiss()
            case .failure:
                break
            }
        }
        .store(withLifetimeOf: viewController)

        presenter.push(viewController: viewController)
    }

    func routeToPriceInput(
        source: BlockchainAccount,
        destination: TransactionTarget,
        transactionModel: TransactionModel,
        action: AssetAction
    ) {

        if viewController.viewControllers.contains(EnterAmountViewController.self) {
            return pop(to: EnterAmountViewController.self)
        }

        guard let source = source as? SingleAccount else { return }
        let builder = EnterAmountPageBuilder(transactionModel: transactionModel)
        let router = builder.build(
            listener: interactor,
            sourceAccount: source,
            destinationAccount: destination,
            action: action,
            navigationModel: ScreenNavigationModel.EnterAmount.navigation(
                allowsBackButton: action.allowsBackButton
            )
        )
        let viewControllable = router.viewControllable
        attachChild(router)
        if let childVC = viewController.uiviewController.children.first,
           childVC is TransactionFlowInitialViewController
        {
            viewController.replaceRoot(viewController: viewControllable, animated: false)
        } else {
            viewController.push(viewController: viewControllable)
        }
    }

    func presentKYCFlowIfNeeded(completion: @escaping (Bool) -> Void) {
        let presenter = topMostViewControllerProvider.topMostViewController ?? viewController.uiviewController
        interactor.listener?.presentKYCFlowIfNeeded(from: presenter, completion: completion)
    }

    func presentKYCUpgradeFlow(completion: @escaping (Bool) -> Void) {
        let presenter = topMostViewControllerProvider.topMostViewController ?? viewController.uiviewController
        kycRouter
            .presentKYCUpgradeFlow(from: presenter)
            .map { result -> Bool in result == .completed }
            .sink(receiveValue: completion)
            .store(in: &cancellables)
    }

    func routeToSecurityChecks(transactionModel: TransactionModel) {
        let presenter = topMostViewControllerProvider.topMostViewController ?? viewController.uiviewController
        securityRouter = PaymentSecurityRouter { result in
            Logger.shared.debug(String(describing: result))
            switch result {
            case .abandoned, .failed:
                transactionModel.process(action: .returnToPreviousStep)
            case .pending, .completed:
                transactionModel.process(action: .securityChecksCompleted)
            }
        }
        transactionModel
            .state
            .asPublisher()
            .first()
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { result in
                    switch result {
                    case .failure(let error):
                        transactionModel.process(action: .fatalTransactionError(error))
                    case .finished:
                        break
                    }
                },
                receiveValue: { [weak self] transactionState in
                    guard let self = self else { return }
                    guard
                        let order = transactionState.order as? OrderDetails,
                        let authorizationData = order.authorizationData
                    else {
                        let error = FatalTransactionError.message("Order should contain authorization data.")
                        return transactionModel.process(action: .fatalTransactionError(error))
                    }
                    self.securityRouter?.presentPaymentSecurity(
                        from: presenter,
                        authorizationData: authorizationData
                    )
                }
            )
            .store(in: &cancellables)
    }

    func presentNewTransactionFlow(
        to action: TransactionFlowAction,
        completion: @escaping (Bool) -> Void
    ) {
        let presenter = topMostViewControllerProvider.topMostViewController ?? viewController.uiviewController
        transactionsRouter
            .presentTransactionFlow(to: action, from: presenter)
            .map { $0 == .completed }
            .sink(receiveValue: completion)
            .store(in: &cancellables)
    }
}

extension TransactionFlowRouter {

    private func present(_ viewControllerToPresent: UIViewController, transitionType: TransitionType) {
        switch transitionType {
        case .modal:
            viewControllerToPresent.isModalInPresentation = true
            viewController.present(viewController: viewControllerToPresent, animated: true)
        case .push:
            viewController.push(viewController: viewControllerToPresent)
        case .replaceRoot:
            viewController.replaceRoot(viewController: viewControllerToPresent, animated: false)
        }
    }

    private func attachAndPresent(_ router: ViewableRouting, transitionType: TransitionType) {
        attachChild(router)
        present(router.viewControllable.uiviewController, transitionType: transitionType)
    }
}

extension TransactionFlowRouter {

    private func sourceAccountPickerRouter(
        with transactionModel: TransactionModel,
        action: AssetAction,
        canAddMoreSources: Bool
    ) -> AccountPickerRouting {
        let subtitle = TransactionFlowDescriptor.AccountPicker.sourceSubtitle(action: action)
        let builder = AccountPickerBuilder(
            accountProvider: TransactionModelAccountProvider(
                transactionModel: transactionModel,
                transform: { $0.availableSources }
            ),
            action: action
        )
        let shouldAddMoreButton = canAddMoreSources && action.supportsAddingSourceAccounts
        let button: ButtonViewModel? = shouldAddMoreButton ? .secondary(with: LocalizationConstants.addNew) : nil
        return builder.build(
            listener: .listener(interactor),
            navigationModel: ScreenNavigationModel.AccountPicker.modal(
                title: TransactionFlowDescriptor.AccountPicker.sourceTitle(action: action)
            ),
            headerModel: subtitle.isEmpty ? .none : .simple(AccountPickerSimpleHeaderModel(subtitle: subtitle)),
            buttonViewModel: button
        )
    }

    private func destinationAccountPicker(
        with transactionModel: TransactionModel,
        navigationModel: ScreenNavigationModel,
        action: AssetAction
    ) -> AccountPickerRouting {
        let subtitle = TransactionFlowDescriptor.AccountPicker.destinationSubtitle(action: action)
        let builder = AccountPickerBuilder(
            accountProvider: TransactionModelAccountProvider(
                transactionModel: transactionModel,
                transform: {
                    $0.availableTargets as? [BlockchainAccount] ?? []
                }
            ),
            action: action
        )
        let button: ButtonViewModel? = action == .withdraw ? .secondary(with: LocalizationConstants.addNew) : nil
        return builder.build(
            listener: .listener(interactor),
            navigationModel: navigationModel,
            headerModel: subtitle.isEmpty ? .none : .simple(AccountPickerSimpleHeaderModel(subtitle: subtitle)),
            buttonViewModel: button
        )
    }
}

extension AssetAction {

    var supportsAddingSourceAccounts: Bool {
        switch self {
        case .buy,
             .deposit:
            return true

        case .sell,
             .withdraw,
             .receive,
             .send,
             .sign,
             .swap,
             .viewActivity,
             .interestWithdraw,
             .linkToDebitCard,
             .interestTransfer:
            return false
        }
    }
}

extension PaymentMethodAccount {
    fileprivate static func applePay(from method: PaymentMethod) -> PaymentMethodAccount {
        PaymentMethodAccount(
            paymentMethodType: PaymentMethodType.applePay(
                CardData(
                    identifier: "",
                    state: .active,
                    partner: .unknown,
                    type: .unknown,
                    currency: method.fiatCurrency,
                    label: LocalizationConstants.Transaction.Buy.applePay,
                    ownerName: "",
                    number: "",
                    month: "",
                    year: "",
                    cvv: "",
                    topLimit: method.max
                )),
            paymentMethod: method
        )
    }
}
