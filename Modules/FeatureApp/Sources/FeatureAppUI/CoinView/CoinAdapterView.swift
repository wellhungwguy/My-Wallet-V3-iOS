//  Copyright © 2021 Blockchain Luxembourg S.A. All rights reserved.

import AnalyticsKit
import BlockchainComponentLibrary
import BlockchainNamespace
import Collections
import Combine
import ComposableArchitecture
import DIKit
import FeatureAppDomain
import FeatureCoinData
import FeatureCoinDomain
import FeatureCoinUI
import FeatureDashboardUI
import FeatureInterestUI
import FeatureKYCUI
import FeatureNFTUI
import FeatureTransactionDomain
import FeatureTransactionUI
import Localization
import MoneyKit
import NetworkKit
import PlatformKit
import PlatformUIKit
import SwiftUI
import ToolKit

public struct CoinAdapterView: View {

    let app: AppProtocol
    let store: Store<CoinViewState, CoinViewAction>
    let cryptoCurrency: CryptoCurrency

    public init(
        cryptoCurrency: CryptoCurrency,
        app: AppProtocol = resolve(),
        userAdapter: UserAdapterAPI = resolve(),
        coincore: CoincoreAPI = resolve(),
        fiatCurrencyService: FiatCurrencyServiceAPI = resolve(),
        assetInformationRepository: AssetInformationRepositoryAPI = resolve(),
        historicalPriceRepository: HistoricalPriceRepositoryAPI = resolve(),
        ratesRepository: RatesRepositoryAPI = resolve(),
        watchlistRepository: WatchlistRepositoryAPI = resolve(),
        recurringBuyProviderRepository: RecurringBuyProviderRepositoryAPI = resolve(),
        cancelRecurringBuyRepository: CancelRecurringBuyRepositoryAPI = resolve(),
        dismiss: @escaping () -> Void
    ) {
        self.cryptoCurrency = cryptoCurrency
        self.app = app
        self.store = Store<CoinViewState, CoinViewAction>(
            initialState: .init(
                currency: cryptoCurrency
            ),
            reducer: coinViewReducer,
            environment: CoinViewEnvironment(
                app: app,
                kycStatusProvider: { [userAdapter] in
                    userAdapter.userState
                        .compactMap { result -> UserState.KYCStatus? in
                            guard case .success(let userState) = result else {
                                return nil
                            }
                            return userState.kycStatus
                        }
                        .map(FeatureCoinDomain.KYCStatus.init)
                        .eraseToAnyPublisher()
                },
                accountsProvider: { [fiatCurrencyService, coincore] in
                    fiatCurrencyService.displayCurrencyPublisher
                        .setFailureType(to: Error.self)
                        .flatMap { [coincore] fiatCurrency in
                            app.modePublisher()
                                .flatMap { _ in
                                    coincore.cryptoAccounts(
                                        for: cryptoCurrency,
                                        filter: app.currentMode.filter
                                    )
                                }
                                .map { accounts in
                                    accounts
                                        .filter { !($0 is ExchangeAccount) }
                                        .map { Account($0, fiatCurrency) }
                                }
                                .eraseToAnyPublisher()
                        }
                        .eraseToAnyPublisher()
                },
                recurringBuyProvider: {
                    app
                        .publisher(for: blockchain.app.configuration.recurring.buy.is.enabled)
                        .replaceError(with: false)
                        .flatMap { [recurringBuyProviderRepository] (isRecurringBuyEnabled) -> AnyPublisher<[FeatureCoinDomain.RecurringBuy], Error> in
                            guard isRecurringBuyEnabled else { return .just([]) }
                            return recurringBuyProviderRepository
                                .fetchRecurringBuysForCryptoCurrency(cryptoCurrency)
                                .map { $0.map(RecurringBuy.init) }
                                .eraseError()
                                .eraseToAnyPublisher()
                        }
                        .eraseToAnyPublisher()
                },
                cancelRecurringBuyService: { (recurringBuyId) -> AnyPublisher<Void, Error> in
                    cancelRecurringBuyRepository
                        .cancelRecurringBuyWithId(recurringBuyId)
                        .eraseError()
                        .eraseToAnyPublisher()
                },
                assetInformationService: AssetInformationService(
                    currency: cryptoCurrency,
                    repository: assetInformationRepository
                ),
                historicalPriceService: HistoricalPriceService(
                    base: cryptoCurrency,
                    displayFiatCurrency: fiatCurrencyService.displayCurrencyPublisher,
                    historicalPriceRepository: historicalPriceRepository
                ),
                earnRatesRepository: ratesRepository,
                explainerService: .init(app: app),
                watchlistService: WatchlistService(
                    base: cryptoCurrency,
                    watchlistRepository: watchlistRepository,
                    app: app
                ),
                dismiss: dismiss
            )
        )
    }

    public var body: some View {
        CoinView(store: store)
            .context([blockchain.ux.asset.id: cryptoCurrency.code])
            .app(app)
    }
}

public final class CoinViewObserver: Client.Observer {

    let app: AppProtocol
    let transactionsRouter: TransactionsRouterAPI
    let coincore: CoincoreAPI
    let kycRouter: KYCRouterAPI
    let defaults: UserDefaults
    let application: URLOpener
    let topViewController: TopMostViewControllerProviding
    let exchangeProvider: ExchangeProviding

    public init(
        app: AppProtocol,
        transactionsRouter: TransactionsRouterAPI = resolve(),
        coincore: CoincoreAPI = resolve(),
        kycRouter: KYCRouterAPI = resolve(),
        defaults: UserDefaults = .standard,
        application: URLOpener = resolve(),
        topViewController: TopMostViewControllerProviding = resolve(),
        exchangeProvider: ExchangeProviding = resolve()
    ) {
        self.app = app
        self.transactionsRouter = transactionsRouter
        self.coincore = coincore
        self.kycRouter = kycRouter
        self.defaults = defaults
        self.application = application
        self.topViewController = topViewController
        self.exchangeProvider = exchangeProvider
    }

    var observers: [BlockchainEventSubscription] {
        [
            activity,
            buy,
            exchangeDeposit,
            exchangeWithdraw,
            explainerReset,
            kyc,
            receive,
            rewardsDeposit,
            rewardsSummary,
            rewardsWithdraw,
            stakingDeposit,
            select,
            sell,
            send,
            swap,
            website,
            recurringBuyLearnMore
        ]
    }

    public func start() {
        for observer in observers {
            observer.start()
        }
    }

    public func stop() {
        for observer in observers {
            observer.stop()
        }
    }

    lazy var select = app.on(blockchain.ux.asset.select.then.enter.into) { @MainActor [unowned self] event async throws in
        guard let action = event.action else { return }
        let destination = try action.data.decode(Tag.Reference.self)
        let cryptoCurrency = try destination.context.decode(blockchain.ux.asset.id) as CryptoCurrency
        let origin = try event.context.decode(blockchain.ux.asset.select.origin) as String
        app.state.transaction { state in
            state.set(blockchain.ux.asset.id, to: cryptoCurrency.code)
            state.set(blockchain.ux.asset[cryptoCurrency.code].select.origin, to: origin)
        }
    }

    lazy var buy = app.on(blockchain.ux.asset.buy, blockchain.ux.asset.account.buy) { @MainActor [unowned self] event in
        try await transactionsRouter.presentTransactionFlow(
            to: .buy(cryptoAccount(for: .buy, from: event))
        )
    }

    lazy var sell = app.on(blockchain.ux.asset.sell, blockchain.ux.asset.account.sell) { @MainActor [unowned self] event in
        try await transactionsRouter.presentTransactionFlow(
            to: .sell(cryptoAccount(for: .sell, from: event))
        )
    }

    lazy var receive = app.on(blockchain.ux.asset.receive, blockchain.ux.asset.account.receive) { @MainActor [unowned self] event in
        try await transactionsRouter.presentTransactionFlow(
            to: .receive(cryptoAccount(for: .receive, from: event))
        )
    }

    lazy var send = app.on(blockchain.ux.asset.send, blockchain.ux.asset.account.send) { @MainActor [unowned self] event in
        try await transactionsRouter.presentTransactionFlow(
            to: .send(cryptoAccount(for: .send, from: event), nil)
        )
    }

    lazy var swap = app.on(blockchain.ux.asset.account.swap) { @MainActor [unowned self] event in
        try await transactionsRouter.presentTransactionFlow(
            to: .swap(cryptoAccount(for: .swap, from: event))
        )
    }

    lazy var rewardsWithdraw = app.on(blockchain.ux.asset.account.rewards.withdraw) { @MainActor [unowned self] event in
        switch try await cryptoAccount(from: event) {
        case let account as CryptoInterestAccount:
            await transactionsRouter.presentTransactionFlow(to: .interestWithdraw(account))
        default:
            throw blockchain.ux.asset.account.error[]
                .error(message: "Withdrawing from rewards requires CryptoInterestAccount")
        }
    }

    lazy var rewardsDeposit = app.on(blockchain.ux.asset.account.rewards.deposit) { @MainActor [unowned self] event in
        switch try await cryptoAccount(from: event) {
        case let account as CryptoInterestAccount:
            await transactionsRouter.presentTransactionFlow(to: .interestTransfer(account))
        default:
            throw blockchain.ux.asset.account.error[]
                .error(message: "Transferring to rewards requires CryptoInterestAccount")
        }
    }

    lazy var rewardsSummary = app.on(blockchain.ux.asset.account.rewards.summary) { @MainActor [unowned self] event in
        let account = try await cryptoAccount(from: event)
        let interactor = InterestAccountDetailsScreenInteractor(account: account)
        let presenter = InterestAccountDetailsScreenPresenter(interactor: interactor)
        let controller = InterestAccountDetailsViewController(presenter: presenter)
        topViewController.topMostViewController?.present(UINavigationController(rootViewController: controller), animated: true, completion: nil)
    }

    lazy var stakingDeposit = app.on(blockchain.ux.asset.account.staking.deposit) { @MainActor [unowned self] event in
        switch try await cryptoAccount(from: event) {
        case let account as CryptoStakingAccount:
            await transactionsRouter.presentTransactionFlow(to: .stakingDeposit(account))
        default:
            throw blockchain.ux.asset.account.error[]
                .error(message: "Transferring to rewards requires CryptoInterestAccount")
        }
    }

    lazy var exchangeWithdraw = app.on(blockchain.ux.asset.account.exchange.withdraw) { @MainActor [unowned self] event in
        try await transactionsRouter.presentTransactionFlow(
            to: .send(
                cryptoAccount(for: .send, from: event),
                custodialAccount(CryptoTradingAccount.self, from: event)
            )
        )
    }

    lazy var exchangeDeposit = app.on(blockchain.ux.asset.account.exchange.deposit) { @MainActor [unowned self] event in
        try await transactionsRouter.presentTransactionFlow(
            to: .send(
                custodialAccount(CryptoTradingAccount.self, from: event),
                cryptoAccount(for: .send, from: event)
            )
        )
    }

    lazy var kyc = app.on(blockchain.ux.asset.account.require.KYC) { @MainActor [unowned self] _ async in
        kycRouter.start(tier: .tier2, parentFlow: .coin)
    }

    lazy var activity = app.on(blockchain.ux.asset.account.activity) { @MainActor [unowned self] _ async in
        self.topViewController.topMostViewController?.dismiss(animated: true) {
            self.app.post(event: blockchain.ux.home.tab[blockchain.ux.user.activity].select)
        }
    }

    lazy var website = app.on(blockchain.ux.asset.bio.visit.website) { [application] event async throws in
        try application.open(event.context.decode(blockchain.ux.asset.bio.visit.website.url, as: URL.self))
    }

    lazy var recurringBuyLearnMore = app.on(blockchain.ux.asset.recurring.buy.visit.website) { [application] event async throws in
        try application.open(event.context.decode(blockchain.ux.asset.recurring.buy.visit.website.url, as: URL.self))
    }

    lazy var explainerReset = app.on(blockchain.ux.asset.account.explainer.reset) { [defaults] _ in
        defaults.removeObject(forKey: blockchain.ux.asset.account.explainer(\.id))
    }

    // swiftlint:disable first_where
    func custodialAccount(
        _ type: BlockchainAccount.Type,
        from event: Session.Event
    ) async throws -> CryptoTradingAccount {
        try await coincore.cryptoAccounts(
            for: event.context.decode(blockchain.ux.asset.id),
            filter: .custodial
        )
        .filter(CryptoTradingAccount.self)
        .first
        .or(
            throw: blockchain.ux.asset.error[]
                .error(message: "No trading account found for \(event.reference)")
        )
    }

    func cryptoAccount(
        for action: AssetAction? = nil,
        from event: Session.Event
    ) async throws -> CryptoAccount {
        let accounts = try await coincore.cryptoAccounts(
            for: event.reference.context.decode(blockchain.ux.asset.id),
            supporting: action
        )
        if let id = try? event.reference.context.decode(blockchain.ux.asset.account.id, as: String.self) {
            return try accounts.first(where: { account in account.identifier as? String == id })
                .or(
                    throw: blockchain.ux.asset.error[]
                        .error(message: "No account found with id \(id)")
                )
        } else {
            let appMode = app.currentMode
            switch appMode {
            case .universal:
                return try(accounts.first(where: { account in account is TradingAccount })
                           ?? accounts.first(where: { account in account is NonCustodialAccount })
                           ?? accounts.first
                )
                .or(
                    throw: blockchain.ux.asset.error[]
                        .error(message: "\(event) has no valid accounts for \(String(describing: action))")
                )

            case .trading:
                return try(
                    accounts.first(where: { account in account is TradingAccount })
                        ?? accounts.first(where: { account in account is InterestAccount })
                        ?? accounts.first(where: { account in account is StakingAccount })
                )
                .or(
                    throw: blockchain.ux.asset.error[]
                        .error(message: "\(event) has no valid accounts for \(String(describing: action))")
                )

            case .pkw:
                return try(accounts.first(where: { account in account is NonCustodialAccount }))
                    .or(
                        throw: blockchain.ux.asset.error[]
                            .error(message: "\(event) has no valid accounts for \(String(describing: action))")
                    )
            }
        }
    }
}

extension FeatureCoinDomain.RecurringBuy {
    init(_ recurringBuy: FeatureTransactionDomain.RecurringBuy) {
        self.init(
            id: recurringBuy.id,
            recurringBuyFrequency: recurringBuy.recurringBuyFrequency.description,
            // Should never be nil as nil is only for one time payments and unknown
            nextPaymentDate: recurringBuy.nextPaymentDateDescription ?? "",
            paymentMethodType: recurringBuy.paymentMethodTypeDescription,
            amount: recurringBuy.amount.displayString,
            asset: recurringBuy.asset.displayCode
        )
    }
}

extension FeatureTransactionDomain.RecurringBuy {
    private typealias L01n = LocalizationConstants.Transaction.Buy.Recurring.PaymentMethod
    fileprivate var paymentMethodTypeDescription: String {
        switch paymentMethodType {
        case .bankTransfer,
                .bankAccount:
            return L01n.bankTransfer
        case .card:
            return L01n.creditOrDebitCard
        case .applePay:
            return L01n.applePay
        case .funds:
            return amount.currency.name + " \(L01n.account)"
        }
    }
}

extension FeatureCoinDomain.Account {
    init(_ account: CryptoAccount, _ fiatCurrency: FiatCurrency) {
        self.init(
            id: account.identifier,
            name: account.label,
            accountType: .init(account),
            cryptoCurrency: account.currencyType.cryptoCurrency!,
            fiatCurrency: fiatCurrency,
            actionsPublisher: {
                account.actions
                    .map { actions in OrderedSet(actions.compactMap(Account.Action.init)) }
                    .eraseToAnyPublisher()
            },
            cryptoBalancePublisher: account.balance.ignoreFailure(),
            fiatBalancePublisher: account.fiatBalance(fiatCurrency: fiatCurrency).ignoreFailure()
        )
    }
}

extension FeatureCoinDomain.Account.Action {

    // swiftlint:disable cyclomatic_complexity
    init?(_ action: AssetAction) {
        switch action {
        case .buy:
            self = .buy
        case .deposit:
            self = .exchange.deposit
        case .interestTransfer:
            self = .rewards.deposit
        case .interestWithdraw:
            self = .rewards.withdraw
        case .stakingDeposit:
            self = .staking.deposit
        case .receive:
            self = .receive
        case .sell:
            self = .sell
        case .send:
            self = .send
        case .linkToDebitCard:
            return nil
        case .sign:
            return nil
        case .swap:
            self = .swap
        case .viewActivity:
            self = .activity
        case .withdraw:
            self = .exchange.withdraw
        }
    }
}

extension FeatureCoinDomain.Account.AccountType {

    init(_ account: CryptoAccount) {
        if account is TradingAccount {
            self = .trading
        } else if account is ExchangeAccount {
            self = .exchange
        } else if account is InterestAccount {
            self = .interest
        } else if account is StakingAccount {
            self = .staking
        } else {
            self = .privateKey
        }
    }
}

extension FeatureCoinDomain.KYCStatus {

    init(_ kycStatus: UserState.KYCStatus) {
        switch kycStatus {
        case .unverified:
            self = .unverified
        case .inReview:
            self = .inReview
        case .silver:
            self = .silver
        case .silverPlus:
            self = .silverPlus
        case .gold:
            self = .gold
        }
    }
}

extension TransactionsRouterAPI {

    @discardableResult
    @MainActor func presentTransactionFlow(to action: TransactionFlowAction) async -> TransactionFlowResult? {
        try? await presentTransactionFlow(to: action).stream().next()
    }
}

extension CoincoreAPI {
    func cryptoAccounts(
        for cryptoCurrency: CryptoCurrency,
        supporting action: AssetAction? = nil,
        filter: AssetFilter = .allExcludingExchange
    ) async throws -> [CryptoAccount] {
        try await cryptoAccounts(for: cryptoCurrency, supporting: action, filter: filter).stream().next()
    }
}
