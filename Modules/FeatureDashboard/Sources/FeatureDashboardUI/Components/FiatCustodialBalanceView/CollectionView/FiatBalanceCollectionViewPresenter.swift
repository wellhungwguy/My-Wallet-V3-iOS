// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import MoneyKit
import PlatformKit
import PlatformUIKit
import RxCocoa
import RxRelay
import RxSwift

final class FiatBalanceCollectionViewPresenter: Equatable {

    // MARK: - Exposed Properties

    var presenters: Driver<[FiatCustodialBalanceViewPresenter]> {
        _ = setup
        return presentersRelay.asDriver()
    }

    var tap: Signal<CurrencyType> {
        tapRelay
            .asSignal()
    }

    // MARK: - Injected Properties

    private let interactor: FiatBalanceCollectionViewInteractor

    // MARK: - Accessors

    private let tapRelay = PublishRelay<CurrencyType>()
    private let presentersRelay = BehaviorRelay<[FiatCustodialBalanceViewPresenter]>(value: [])
    private let disposeBag = DisposeBag()

    private lazy var setup: Void = interactor.interactors
        .map { interactors in
            interactors.map {
                FiatCustodialBalanceViewPresenter(
                    interactor: $0,
                    descriptors: .dashboard(),
                    respondsToTaps: false,
                    presentationStyle: interactors.count > 1 ? .border : .plain
                )
            }
        }
        .bindAndCatch(to: presentersRelay)
        .disposed(by: disposeBag)

    // MARK: - Setup

    init(interactor: FiatBalanceCollectionViewInteractor) {
        self.interactor = interactor
    }

    // MARK: - Public

    func selected(currencyType: CurrencyType) {
        tapRelay.accept(currencyType)
    }

    func refresh() {
        _ = setup
        interactor.refresh()
    }

    // Equatable
    static func == (lhs: FiatBalanceCollectionViewPresenter, rhs: FiatBalanceCollectionViewPresenter) -> Bool {
        lhs.interactor.interactorsStateRelay.value == rhs.interactor.interactorsStateRelay.value
    }
}
