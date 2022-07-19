// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import DIKit
import MoneyKit
import PlatformKit
import RxRelay
import RxSwift
import RxToolKit
import ToolKit

// swiftformat:disable all

struct PortfolioBalanceChange {
    let balance: MoneyValue
    let changePercentage: Decimal
    let change: MoneyValue
}

final class PortfolioBalanceChangeProvider {

    // MARK: - Exposed Properties

    var changeObservable: Observable<ValueCalculationState<PortfolioBalanceChange>> {
        changeRelay.asObservable()
    }

    // MARK: - Private Properties

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
                fiatCurrency,
                didRefresh
            )
            .map(\.0)
            .flatMapLatest { [coincore] fiatCurrency in
                Self.fetch(coincore: coincore, fiatCurrency: fiatCurrency)
                    .asObservable()
                    .map { .value($0) }
                    .catchAndReturn(.calculating)
            }
            .catchAndReturn(.calculating)
            .bindAndCatch(to: changeRelay)
            .disposed(by: disposeBag)
    }()

    private static func fetch(
        coincore: CoincoreAPI,
        fiatCurrency: FiatCurrency
    ) -> AnyPublisher<PortfolioBalanceChange, Error> {
        coincore.allAccounts
            .eraseError()
            .flatMap { accountGroup in
                accountGroup.fiatBalance(fiatCurrency: fiatCurrency)
                    .zip(accountGroup.fiatBalance(fiatCurrency: fiatCurrency, at: .oneDay))
                    .eraseToAnyPublisher()
                    .eraseError()
            }
            .tryMap { currentBalance, previousBalance in
                let percentage: Decimal // in range [0...1]
                let change = try currentBalance - previousBalance
                if currentBalance.isZero {
                    percentage = 0
                } else {
                    // `zero` shouldn't be possible but is handled in any case
                    // in a way that would not throw
                    if previousBalance.isZero || previousBalance.isNegative {
                        percentage = 0
                    } else {
                        percentage = try change.percentage(in: previousBalance)
                    }
                }
                return PortfolioBalanceChange(
                    balance: currentBalance,
                    changePercentage: percentage,
                    change: change
                )
            }
            .eraseToAnyPublisher()
    }

    private let coincore: CoincoreAPI
    private let fiatCurrencyService: FiatCurrencyServiceAPI
    private let changeRelay = BehaviorRelay<ValueCalculationState<PortfolioBalanceChange>>(value: .calculating)
    private let refreshRelay = PublishRelay<Void>()
    private let disposeBag = DisposeBag()

    // MARK: - Setup

    init(
        coincore: CoincoreAPI = resolve(),
        fiatCurrencyService: FiatCurrencyServiceAPI = resolve()
    ) {
        self.coincore = coincore
        self.fiatCurrencyService = fiatCurrencyService
        _ = setup
    }

    // MARK: - Functions

    func refreshBalance() {
        refreshRelay.accept(())
    }
}
