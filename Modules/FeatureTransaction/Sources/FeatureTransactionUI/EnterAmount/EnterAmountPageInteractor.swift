// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainNamespace
import Combine
import DIKit
import Errors
import FeatureFormDomain
import FeatureTransactionDomain
import Localization
import MoneyKit
import PlatformKit
import PlatformUIKit
import RIBs
import RxCocoa
import RxSwift
import ToolKit

protocol EnterAmountPageRouting: AnyObject {
    func showFeeSelectionSheet(with transactionModel: TransactionModel)
    func showError(_ error: Error)
}

protocol EnterAmountPageListener: AnyObject {
    func enterAmountDidTapBack()
    func enterAmountDidTapAuxiliaryButton()
    func closeFlow()
    func showGenericFailure(error: Error)
}

protocol EnterAmountPagePresentable: Presentable {

    var continueButtonTapped: Signal<Void> { get }

    func presentWithdrawalLocks(amountAvailable: String)

    func connect(
        state: Driver<EnterAmountPageInteractor.State>
    ) -> Driver<EnterAmountPageInteractor.NavigationEffects>
}

protocol AuxiliaryViewPresenting: AnyObject {

    func makeViewController() -> UIViewController
}

protocol AuxiliaryViewPresentingDelegate: AnyObject {

    func auxiliaryViewTapped(_ presenter: AuxiliaryViewPresenting, state: TransactionState)
}

final class EnterAmountPageInteractor: PresentableInteractor<EnterAmountPagePresentable>, EnterAmountPageInteractable {

    weak var router: EnterAmountPageRouting?
    weak var listener: EnterAmountPageListener?

    private var topAuxiliaryViewPresenter: AuxiliaryViewPresenting?

    /// The interactor that `SendAuxiliaryViewPresenter` uses
    private let sendAuxiliaryViewInteractor: SendAuxiliaryViewInteractor
    private let sendAuxiliaryViewPresenter: SendAuxiliaryViewPresenter

    private let accountAuxiliaryViewInteractor: AccountAuxiliaryViewInteractor
    private let accountAuxiliaryViewPresenter: AccountAuxiliaryViewPresenter

    /// The interactor that `SingleAmountPresenter` uses
    private let amountViewInteractor: AmountViewInteracting

    private let app: AppProtocol
    private let transactionModel: TransactionModel
    private let action: AssetAction
    private let navigationModel: ScreenNavigationModel

    private let analyticsHook: TransactionAnalyticsHook
    private let eventsRecorder: Recording

    private let restrictionsProvider: TransactionRestrictionsProviderAPI

    init(
        transactionModel: TransactionModel,
        presenter: EnterAmountPagePresentable,
        amountInteractor: AmountViewInteracting,
        action: AssetAction,
        navigationModel: ScreenNavigationModel,
        restrictionsProvider: TransactionRestrictionsProviderAPI = resolve(),
        analyticsHook: TransactionAnalyticsHook = resolve(),
        app: AppProtocol = resolve(),
        eventsRecorder: Recording = resolve(tag: "CrashlyticsRecorder")
    ) {
        self.action = action
        self.app = app
        self.transactionModel = transactionModel
        amountViewInteractor = amountInteractor
        self.navigationModel = navigationModel
        self.restrictionsProvider = restrictionsProvider
        self.analyticsHook = analyticsHook
        self.eventsRecorder = eventsRecorder
        sendAuxiliaryViewInteractor = SendAuxiliaryViewInteractor()
        sendAuxiliaryViewPresenter = SendAuxiliaryViewPresenter(
            interactor: sendAuxiliaryViewInteractor
        )
        accountAuxiliaryViewInteractor = AccountAuxiliaryViewInteractor()
        accountAuxiliaryViewPresenter = AccountAuxiliaryViewPresenter(
            interactor: accountAuxiliaryViewInteractor
        )
        super.init(presenter: presenter)
    }

    // TODO: Clean up this function
    // swiftlint:disable function_body_length
    // swiftlint:disable cyclomatic_complexity
    override func didBecomeActive() {
        super.didBecomeActive()

        let transactionState: Observable<TransactionState> = transactionModel
            .state
            .share(replay: 1, scope: .whileConnected)

        amountViewInteractor
            .effect
            .subscribe { [weak self] effect in
                self?.handleAmountTranslation(effect: effect)
            }
            .disposeOnDeactivate(interactor: self)

        amountViewInteractor
            .auxiliaryButtonTappedRelay
            .asObservable()
            .subscribe(on: MainScheduler.asyncInstance)
            .subscribe(
                onNext: { [listener] in
                    listener?.enterAmountDidTapAuxiliaryButton()
                }
            )
            .disposeOnDeactivate(interactor: self)

        amountViewInteractor
            .amount
            .debounce(.milliseconds(250), scheduler: MainScheduler.asyncInstance)
            .distinctUntilChanged()
            .flatMap { amount -> Observable<MoneyValue> in
                transactionState
                    .take(1)
                    .asSingle()
                    .map { state in
                        if let fiatValue = amount.fiatValue, !state.allowFiatInput {
                            // Fiat Input but state does not allow fiat
                            guard let exchangeRate = state.exchangeRates?.fiatTradingCurrencyToSourceRate else {
                                return .zero(currency: state.asset)
                            }
                            return fiatValue.convert(using: exchangeRate)
                        }
                        return amount
                    }
                    .asObservable()
            }
            .subscribe(on: MainScheduler.asyncInstance)
            .subscribe { [weak self] (amount: MoneyValue) in
                self?.transactionModel.process(action: .updateAmount(amount))
            }
            .disposeOnDeactivate(interactor: self)

        transactionState
            .compactMap(\.initialAmountToSet)
            .take(1)
            .asSingle()
            .subscribe(on: MainScheduler.asyncInstance)
            .subscribe { [weak self] (amount: MoneyValue) in
                // On the first time initialAmountToSet is available,
                // we will set it to AmountViewInteractor, so the UI
                // is up to date with the State.
                self?.amountViewInteractor.set(amount: amount)
            }
            .disposeOnDeactivate(interactor: self)

        Task(priority: .userInitiated) {

            guard try await app.get(
                blockchain.app.configuration.transaction.should.prefill.with.previous.amount
            ) else { return }

            let previous = blockchain.ux.transaction.source.target.previous

            guard try await app.get(previous.did.error) else { return }

            let money = try await MoneyValue(
                amount: app.get(previous.input.amount),
                currency: CurrencyType(code: app.get(previous.input.currency.code))
            )
            await MainActor.run {
                amountViewInteractor.set(amount: money)
            }
        }

        let spendable = Observable
            .combineLatest(
                transactionState,
                amountViewInteractor.activeInput
            )
            .map { state, input in
                (
                    min: state.minSpendableWithActiveAmountInputType(input),
                    max: state.maxSpendableWithActiveAmountInputType(input),
                    cryptoMax: state.maxSpendableWithCryptoInputType()
                )
            }
            .share(scope: .whileConnected)

        transactionState
            .distinctUntilChanged(\.feeSelection, comparer: { $0 == $1 })
            .filter { $0.feeSelection.selectedLevel != .none }
            .subscribe(onNext: { [analyticsHook] state in
                analyticsHook.onFeeSelected(state: state)
            })
            .disposeOnDeactivate(interactor: self)

        amountViewInteractor.maxAmountSelected
            .withLatestFrom(transactionState)
            .subscribe(onNext: analyticsHook.onMaxSelected(state:))
            .disposeOnDeactivate(interactor: self)

        amountViewInteractor.minAmountSelected
            .withLatestFrom(transactionState)
            .subscribe(onNext: analyticsHook.onMinSelected(state:))
            .disposeOnDeactivate(interactor: self)

        let fee = transactionState
            .take(while: { $0.action == .send })
            .compactMap(\.pendingTransaction)
            .map(\.feeAmount)
            .share(scope: .whileConnected)

        let auxiliaryViewAccount = transactionState
            .take(while: { $0.action.supportsBottomAccountsView })
            .map { state -> BlockchainAccount? in
                switch state.action {
                case .buy,
                     .deposit,
                     .interestTransfer:
                    return state.source
                case .sell,
                     .withdraw,
                     .interestWithdraw:
                    return state.destination as? BlockchainAccount
                case .viewActivity,
                     .send,
                     .sign,
                     .linkToDebitCard,
                     .receive,
                     .swap:
                    fatalError("Unsupported action")
                }
            }
            .compactMap { $0 }
            .share(scope: .whileConnected)

        let availableSources = transactionState
            .map(\.availableSources)
            .share(scope: .whileConnected)

        let availableTargets = transactionState
            .map(\.availableTargets)
            .share(scope: .whileConnected)

        let bottomAuxiliaryAccounts = Observable
            .zip(
                availableSources,
                availableTargets
            )
            .compactMap { [action] availableSources, availableTargets -> [Account]? in
                guard action == .buy || action == .deposit else {
                    return availableTargets
                }
                return availableSources
            }

        let userKYCTier = transactionState
            .map(\.userKYCStatus)
            .map(\.?.tiers.latestApprovedTier)
            .share(scope: .whileConnected)

        let bottomAuxiliaryViewEnabled = Observable
            .combineLatest(
                userKYCTier,
                bottomAuxiliaryAccounts
            )
            .map { [action] userKYCTier, accounts -> Bool in
                guard let userKYCTier = userKYCTier, action == .buy && userKYCTier < .tier2 else {
                    return !accounts.isEmpty
                }
                // SDD eligible users cannot add more than 1 payment method so they should have no suggested accounts they can link.
                // Non-SDD eligible users will have a set of suggested accounts they can link, so the button should be enabled.
                let suggestedPaymentMethods: [Account] = accounts
                    .compactMap { $0 as? PaymentMethodAccount }
                    .filter(\.paymentMethodType.isSuggested)
                // Checking for accounts > 1 just in case we allowed some SDD users to add more than 1 payment methods
                return accounts.count > 1 || suggestedPaymentMethods.count > 1
            }

        accountAuxiliaryViewInteractor
            .connect(
                stream: auxiliaryViewAccount,
                tapEnabled: bottomAuxiliaryViewEnabled
            )
            .disposeOnDeactivate(interactor: self)

        accountAuxiliaryViewInteractor
            .auxiliaryViewTapped
            .withLatestFrom(transactionState)
            .subscribe(onNext: { [weak self] state in
                self?.handleBottomAuxiliaryViewTapped(state: state)
            })
            .disposeOnDeactivate(interactor: self)

        sendAuxiliaryViewInteractor
            .connect(fee: fee)
            .disposeOnDeactivate(interactor: self)

        sendAuxiliaryViewInteractor
            .connect(stream: spendable.map(\.max))
            .disposeOnDeactivate(interactor: self)

        sendAuxiliaryViewInteractor
            .resetToMaxAmount
            .withLatestFrom(spendable.map(\.cryptoMax))
            .subscribe(onNext: { [weak self] maxSpendable in
                self?.amountViewInteractor.set(amount: maxSpendable)
            })
            .disposeOnDeactivate(interactor: self)

        sendAuxiliaryViewInteractor
            .resetToMaxAmount
            .withLatestFrom(transactionState)
            .subscribe(onNext: { [analyticsHook] state in
                analyticsHook.onMaxSelected(state: state)
            })
            .disposeOnDeactivate(interactor: self)

        sendAuxiliaryViewInteractor
            .availableBalanceTapped
            .withLatestFrom(spendable.map(\.cryptoMax))
            .subscribe(onNext: { [weak self] maxSpendable in
                self?.amountViewInteractor.set(amount: maxSpendable)
            })
            .disposeOnDeactivate(interactor: self)

        sendAuxiliaryViewInteractor
            .networkFeeTapped
            .bindAndCatch(weak: self) { (self, _) in
                self.router?.showFeeSelectionSheet(with: self.transactionModel)
            }
            .disposeOnDeactivate(interactor: self)

        Observable
            .combineLatest(
                transactionState,
                amountViewInteractor.activeInput
            )
            .map { [restrictionsProvider] state, input in
                state.toAmountInteractorStateWithActiveInput(
                    input,
                    maxTransactionsCount: restrictionsProvider.maximumNumbersOfTransactions(for: state.action)
                )
            }
            .bindAndCatch(to: amountViewInteractor.stateRelay)
            .disposeOnDeactivate(interactor: self)

        let interactorState = transactionState
            .subscribe(on: MainScheduler.asyncInstance)
            .scan(initialState()) { [weak self] currentState, updater -> State in
                guard let self = self else {
                    return currentState
                }
                return self.calculateNextState(
                    with: currentState,
                    updater: updater
                )
            }
            .asDriverCatchError()

        presenter
            .continueButtonTapped
            .asObservable()
            .withLatestFrom(transactionState)
            .subscribe(onNext: { [transactionModel, analyticsHook] state in
                analyticsHook.onEnterAmountContinue(with: state)
                switch state.action {
                case .buy:
                    if state.userKYCStatus?.canPurchaseCrypto == true {
                        transactionModel.process(action: .validateSourceAccount)
                    } else {
                        transactionModel.process(action: .performKYCChecks)
                    }
                default:
                    transactionModel.process(action: .prepareTransaction)
                }
            })
            .disposeOnDeactivate(interactor: self)

        presenter
            .connect(state: interactorState)
            .drive(onNext: handle(effects:))
            .disposeOnDeactivate(interactor: self)

        transactionState
            .compactMap { state -> (action: AssetAction, amountIsZero: Bool, networkFeeAdjustmentSupported: Bool)? in
                guard let pendingTransaction = state.pendingTransaction else {
                    return nil
                }
                return (
                    state.action,
                    state.amount.isZero,
                    pendingTransaction.availableFeeLevels.networkFeeAdjustmentSupported
                )
            }
            .map { action, amountIsZero, networkFeeAdjustmentSupported in
                (action, (networkFeeAdjustmentSupported && action == .send && !amountIsZero) ? .visible : .hidden)
            }
            .map { action, networkFeeVisibility -> SendAuxiliaryViewPresenter.State in
                SendAuxiliaryViewPresenter.State(
                    maxButtonVisibility: networkFeeVisibility.inverted,
                    networkFeeVisibility: networkFeeVisibility,
                    bitpayVisibility: .hidden,
                    availableBalanceTitle: TransactionFlowDescriptor.availableBalanceTitle,
                    maxButtonTitle: TransactionFlowDescriptor.maxButtonTitle(action: action)
                )
            }
            .bindAndCatch(to: sendAuxiliaryViewPresenter.stateRelay)
            .disposeOnDeactivate(interactor: self)
    }

    // swiftlint:enable function_body_length
    // swiftlint:enable cyclomatic_complexity

    // MARK: - Private methods

    private func handleTopAuxiliaryViewTapped(state: TransactionState) {
        switch state.action {
        case .buy:
            transactionModel.process(action: .showTargetSelection)
        case .withdraw:
            presenter.presentWithdrawalLocks(amountAvailable: state.maxSpendable.displayString)
        default:
            break
        }
    }

    private func handleBottomAuxiliaryViewTapped(state: TransactionState) {
        switch state.action {
        case .buy,
             .deposit:
            transactionModel.process(action: .showSourceSelection)
        case .sell,
             .withdraw:
            transactionModel.process(action: .showTargetSelection)
        default:
            unimplemented()
        }
    }

    private func calculateNextState(
        with state: State,
        updater: TransactionState
    ) -> State {
        state
            .update(\.errorState, value: updater.errorState)
            .update(\.canContinue, value: updater.nextEnabled)
            .update(\.showErrorRecoveryAction, value: canShowErrorAction(for: updater))
            .update(\.topAuxiliaryViewPresenter, value: topAuxiliaryView(for: updater))
            .update(\.bottomAuxiliaryViewPresenter, value: bottomAuxiliaryView(for: updater))
            .update(\.showWithdrawalLocks, value: updater.destination is NonCustodialAccount)
    }

    private func canShowContinueAction(for state: TransactionState) -> Bool {
        state.errorState == .none && state.pendingTransaction?.amount.isZero == false
    }

    private func canShowErrorAction(for state: TransactionState) -> Bool {
        state.errorState != .none && state.pendingTransaction?.amount.isZero == false
    }

    private func topAuxiliaryView(for transactionState: TransactionState) -> AuxiliaryViewPresenting? {
        let presenter: AuxiliaryViewPresenting?
        if transactionState.action.supportsTopAccountsView {
            presenter = TargetAuxiliaryViewPresenter(
                delegate: self,
                transactionState: transactionState,
                eventsRecorder: eventsRecorder
            )
        } else {
            presenter = InfoAuxiliaryViewPresenter(
                transactionState: transactionState,
                delegate: self
            )
        }
        topAuxiliaryViewPresenter = presenter
        return presenter
    }

    private func bottomAuxiliaryView(for transactionState: TransactionState) -> AuxiliaryViewPresenting? {
        action.supportsBottomAccountsView ? accountAuxiliaryViewPresenter : sendAuxiliaryViewPresenter
    }

    private func handle(effects: NavigationEffects) {
        switch effects {
        case .back:
            listener?.enterAmountDidTapBack()
        case .close:
            listener?.closeFlow()
        case .none:
            break
        }
    }

    private func handleAmountTranslation(effect: AmountInteractorEffect) {
        switch effect {
        case .failure(let error):
            listener?.showGenericFailure(error: error)
        case .none:
            break
        }
    }
}

extension EnterAmountPageInteractor {

    struct State: Equatable {
        var topAuxiliaryViewPresenter: AuxiliaryViewPresenting?
        var bottomAuxiliaryViewPresenter: AuxiliaryViewPresenting?
        var navigationModel: ScreenNavigationModel
        var canContinue: Bool
        var showErrorRecoveryAction: Bool
        var showWithdrawalLocks: Bool
        var errorState: TransactionErrorState

        static func == (lhs: EnterAmountPageInteractor.State, rhs: EnterAmountPageInteractor.State) -> Bool {
            lhs.topAuxiliaryViewPresenter === rhs.topAuxiliaryViewPresenter
                && lhs.bottomAuxiliaryViewPresenter === rhs.bottomAuxiliaryViewPresenter
                && lhs.navigationModel == rhs.navigationModel
                && lhs.canContinue == rhs.canContinue
                && lhs.errorState == rhs.errorState
                && lhs.showErrorRecoveryAction == rhs.showErrorRecoveryAction
                && lhs.showWithdrawalLocks == rhs.showWithdrawalLocks
        }
    }

    private func initialState() -> State {
        State(
            topAuxiliaryViewPresenter: nil,
            bottomAuxiliaryViewPresenter: nil,
            navigationModel: navigationModel,
            canContinue: false,
            showErrorRecoveryAction: false,
            showWithdrawalLocks: false,
            errorState: .none
        )
    }
}

extension EnterAmountPageInteractor: AuxiliaryViewPresentingDelegate {

    func auxiliaryViewTapped(_ presenter: AuxiliaryViewPresenting, state: TransactionState) {
        if presenter === topAuxiliaryViewPresenter {
            handleTopAuxiliaryViewTapped(state: state)
        } else {
            handleBottomAuxiliaryViewTapped(state: state)
        }
    }
}

extension EnterAmountPageInteractor {

    enum NavigationEffects {
        case back
        case close
        case none
    }
}

extension EnterAmountPageInteractor.State {

    func update<Value>(_ keyPath: WritableKeyPath<Self, Value>, value: Value) -> Self {
        var updated = self
        updated[keyPath: keyPath] = value
        return updated
    }
}

extension TransactionState {

    private typealias LocalizedString = LocalizationConstants.Transaction

    func toAmountInteractorStateWithActiveInput(
        _ activeInput: ActiveAmountInput,
        maxTransactionsCount: Int?
    ) -> AmountInteractorState {
        let message: AmountInteractorState.MessageState
        if let maxTransactionsCount = maxTransactionsCount {
            message = .info(message: LocalizedString.Notices.maxTransactionsLimited(to: maxTransactionsCount))
        } else {
            message = .none
        }

        switch errorState {
        case .none:
            return .validInput(message)

        case .belowFees:
            return .invalidInput(message)

        case .overMaximumSourceLimit,
             .overMaximumPersonalLimit,
             .insufficientFunds:
            return .invalidInput(message)

        case .belowMinimumLimit:
            guard !amount.isZero else {
                return .validInput(message)
            }
            return .invalidInput(message)

        case .addressIsContract,
             .invalidAddress,
             .invalidPassword,
             .optionInvalid,
             .transactionInFlight,
             .pendingOrdersLimitReached,
             .unknownError,
             .nabuError,
             .fatalError:
            return .invalidInput(.none)
        }
    }
}

extension AssetAction {

    fileprivate var supportsTopAccountsView: Bool {
        switch self {
        case .buy:
            return true
        default:
            return false
        }
    }

    fileprivate var supportsBottomAccountsView: Bool {
        switch self {
        case .buy,
             .deposit,
             .withdraw:
            return true
        default:
            return false
        }
    }
}
