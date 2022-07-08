// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import PlatformKit
import PlatformUIKit
import RxRelay
import RxSwift

final class PreferredCurrencyBadgePresenter: BadgeAssetPresenting {

    typealias PresentationState = BadgeAsset.State.BadgeItem.Presentation

    var state: Observable<PresentationState> {
        stateRelay.asObservable()
    }

    // MARK: - Private Accessors

    private let interactor: DefaultBadgeAssetInteractor
    private let stateRelay = BehaviorRelay<PresentationState>(value: .loading)
    private let disposeBag = DisposeBag()

    init(interactor: DefaultBadgeAssetInteractor) {
        self.interactor = interactor
        interactor.state
            .map { .init(with: $0) }
            .bindAndCatch(to: stateRelay)
            .disposed(by: disposeBag)
    }
}
