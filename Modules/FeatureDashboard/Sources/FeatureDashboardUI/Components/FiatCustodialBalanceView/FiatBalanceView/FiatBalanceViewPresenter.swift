// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import PlatformKit
import PlatformUIKit
import RxCocoa
import RxRelay
import RxSwift

final class FiatBalanceViewPresenter {

    // MARK: - Types

    typealias PresentationState = FiatBalanceViewAsset.State.Presentation

    // MARK: - Exposed Properties

    var state: Driver<PresentationState> {
        stateRelay.asDriver()
    }

    var alignment: Driver<UIStackView.Alignment> {
        alignmentRelay.asDriver()
    }

    // MARK: - Injected

    private let interactor: FiatBalanceViewInteractor

    // MARK: - Private Accessors

    private let alignmentRelay = BehaviorRelay<UIStackView.Alignment>(value: .fill)
    private let stateRelay = BehaviorRelay<PresentationState>(value: .loading)
    private let disposeBag = DisposeBag()

    // MARK: - Setup

    init(
        alignment: UIStackView.Alignment = .fill,
        interactor: FiatBalanceViewInteractor,
        descriptors: FiatBalanceViewAsset.Value.Presentation.Descriptors
    ) {
        self.interactor = interactor
        alignmentRelay.accept(alignment)

        // Map interaction state into presentation state
        // and bind it to `stateRelay`
        interactor.state
            .map {
                .init(with: $0, descriptors: descriptors)
            }
            .bindAndCatch(to: stateRelay)
            .disposed(by: disposeBag)
    }
}
