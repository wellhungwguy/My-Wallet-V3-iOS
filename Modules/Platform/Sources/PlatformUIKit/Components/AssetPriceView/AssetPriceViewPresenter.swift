// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import PlatformKit
import RxCocoa
import RxRelay
import RxSwift

public final class AssetPriceViewPresenter {

    typealias PresentationState = DashboardAsset.State.AssetPrice.Presentation

    // MARK: - Exposed Properties

    var state: Observable<PresentationState> {
        _ = setup
        return stateRelay
            .observe(on: MainScheduler.instance)
    }

    var alignment: Driver<UIStackView.Alignment> {
        alignmentRelay.asDriver()
    }

    // MARK: - Injected

    private let interactor: AssetPriceViewInteracting

    // MARK: - Private Accessors

    private lazy var setup: Void = {
        // Map interaction state into presentation state
        // and bind it to `stateRelay`
        interactor.state
            .map(weak: self) { (self, state) -> PresentationState in
                PresentationState(with: state, descriptors: self.descriptors)
            }
            .bindAndCatch(to: stateRelay)
            .disposed(by: disposeBag)
    }()

    private let descriptors: DashboardAsset.Value.Presentation.AssetPrice.Descriptors

    private let alignmentRelay: BehaviorRelay<UIStackView.Alignment>
    private let stateRelay = BehaviorRelay<PresentationState>(value: .loading)
    private let disposeBag = DisposeBag()

    // MARK: - Setup

    public init(
        interactor: AssetPriceViewInteracting,
        alignment: UIStackView.Alignment = .fill,
        descriptors: DashboardAsset.Value.Presentation.AssetPrice.Descriptors
    ) {
        self.interactor = interactor
        self.descriptors = descriptors
        self.alignmentRelay = BehaviorRelay<UIStackView.Alignment>(value: alignment)
    }

    // MARK: - Public Functions

    public func refresh() {
        interactor.refresh()
    }
}
