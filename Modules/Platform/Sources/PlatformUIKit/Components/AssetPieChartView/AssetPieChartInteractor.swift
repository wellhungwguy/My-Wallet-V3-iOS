// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainNamespace
import ComposableArchitectureExtensions
import MoneyKit
import PlatformKit
import RxRelay
import RxSwift

// swiftformat:disable all

public final class AssetPieChartInteractor: AssetPieChartInteracting {

    // MARK: - Properties

    public var state: Observable<AssetPieChart.State.Interaction> {
        _ = setup
        return stateRelay.asObservable()
    }

    // MARK: - Private Accessors

    private var fiatCurrency: Observable<FiatCurrency> {
        fiatCurrencyService.displayCurrencyPublisher.asObservable()
    }

    private var didRefresh: Observable<Void> {
        refreshRelay
            .debounce(
                .milliseconds(500),
                scheduler: ConcurrentDispatchQueueScheduler(qos: .userInitiated)
            )
    }

    private lazy var setup: Void = {
        Observable
            .combineLatest(
                didRefresh,
                fiatCurrency,
                app.modePublisher().asObservable()
            )
            .flatMapLatest { [coincore, app] _, fiatCurrency, appMode -> Observable<AssetPieChart.State.Interaction> in
                guard appMode != .pkw else {
                    return Observable.just(.loaded(next: []))
                }

                let cryptoStreams: [Observable<MoneyValuePair>] = coincore.cryptoAssets.map { asset in
                    asset
                        .accountGroup(filter: .allExcludingExchange)
                        .compactMap({ $0 })
                        .flatMap { accountGroup in
                            if app.remoteConfiguration.yes(
                                if: blockchain.app.configuration.ui.payments.improvements.wallet.balances.is.enabled
                            ) {
                                return accountGroup.mainBalanceToDisplayPair(fiatCurrency: fiatCurrency)
                            } else {
                                return accountGroup.balancePair(fiatCurrency: fiatCurrency)
                            }
                        }
                        .asObservable()
                }
                let fiatStream: Observable<MoneyValuePair> = coincore.fiatAsset
                    .accountGroup(filter: .allExcludingExchange)
                    .compactMap({ $0 })
                    .flatMap { accountGroup in
                        if app.remoteConfiguration.yes(
                            if: blockchain.app.configuration.ui.payments.improvements.wallet.balances.is.enabled
                        ) {
                            return accountGroup.fiatMainBalanceToDisplay(fiatCurrency: fiatCurrency)
                                .map { MoneyValuePair(base: $0, quote: $0) }
                        } else {
                            return accountGroup.fiatBalance(fiatCurrency: fiatCurrency)
                                .map { MoneyValuePair(base: $0, quote: $0) }
                        }
                    }
                    .asObservable()

                return Observable.combineLatest(cryptoStreams + [fiatStream])
                    .map { (pairs: [MoneyValuePair]) -> AssetPieChart.State.Interaction in
                        let total: MoneyValue = try pairs.map(\.quote)
                            .reduce(MoneyValue.zero(currency: fiatCurrency), +)

                        guard total.isPositive else {
                            return .loaded(next: [])
                        }

                        let states = pairs.map { pair in
                            AssetPieChart.Value.Interaction(
                                asset: pair.base.currency,
                                percentage: (try? pair.quote.percentage(in: total)) ?? 0
                            )
                        }
                        return .loaded(next: states)
                    }
            }
            .catchAndReturn(.loading)
            .bindAndCatch(to: stateRelay)
            .disposed(by: disposeBag)
    }()

    private let coincore: CoincoreAPI
    private let disposeBag = DisposeBag()
    private let fiatCurrencyService: FiatCurrencyServiceAPI
    private let stateRelay = BehaviorRelay<AssetPieChart.State.Interaction>(value: .loading)
    private let refreshRelay = BehaviorRelay<Void>(value: ())
    private let app: AppProtocol

    // MARK: - Setup

    public init(
        coincore: CoincoreAPI,
        fiatCurrencyService: FiatCurrencyServiceAPI,
        app: AppProtocol
    ) {
        self.coincore = coincore
        self.fiatCurrencyService = fiatCurrencyService
        self.app = app
    }

    public func refresh() {
        refreshRelay.accept(())
    }
}
