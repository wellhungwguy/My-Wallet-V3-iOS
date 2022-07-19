// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit
import MoneyKit
import PlatformKit
import RxRelay
import RxSwift

final class FiatBalanceViewInteractor {

    // MARK: - Types

    typealias InteractionState = FiatBalanceViewAsset.State.Interaction

    // MARK: - Exposed Properties

    var state: Observable<InteractionState> {
        stateRelay.asObservable()
    }

    // MARK: - Private Accessors

    private let stateRelay = BehaviorRelay<InteractionState>(value: .loading)
    private let disposeBag = DisposeBag()

    init(
        account: SingleAccount,
        fiatCurrencyService: FiatCurrencyServiceAPI = resolve()
    ) {
        fiatCurrencyService
            .displayCurrencyPublisher
            .asObservable()
            .flatMapLatest { fiatCurrency in
                account.balancePair(fiatCurrency: fiatCurrency).asObservable()
            }
            .catchAndReturn(.zero(baseCurrency: account.currencyType, quoteCurrency: account.currencyType))
            .map { moneyValuePair -> FiatBalanceViewAsset.Value.Interaction in
                .init(base: moneyValuePair.base, quote: moneyValuePair.quote)
            }
            .map { FiatBalanceViewAsset.State.Interaction.loaded(next: $0) }
            .bindAndCatch(to: stateRelay)
            .disposed(by: disposeBag)
    }

    init(balance: MoneyValue) {
        stateRelay.accept(
            .loaded(
                next: .init(
                    base: balance,
                    quote: balance
                )
            )
        )
    }
}
