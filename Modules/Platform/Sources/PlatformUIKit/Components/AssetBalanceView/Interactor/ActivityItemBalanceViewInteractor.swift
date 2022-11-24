// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import PlatformKit
import RxRelay
import RxSwift

public final class ActivityItemBalanceViewInteractor: AssetBalanceViewInteracting {

    public typealias InteractionState = AssetBalanceViewModel.State.Interaction

    public var state: Observable<InteractionState> {
        stateRelay.asObservable()
    }

    // MARK: - Private Accessors

    private let stateRelay = BehaviorRelay<InteractionState>(value: .loading)
    private let disposeBag = DisposeBag()
    private let balanceFetch: ActivityItemBalanceFetching

    // MARK: - Setup

    public init(activityItemBalanceFetching: ActivityItemBalanceFetching) {
        self.balanceFetch = activityItemBalanceFetching
        activityItemBalanceFetching
            .calculationState
            .map { state -> InteractionState in
                switch state {
                case .calculating, .invalid:
                    return .loading
                case .value(let result):
                    return .loaded(
                        next: .init(
                            primaryValue: result.base,
                            secondaryValue: result.quote,
                            pendingValue: nil
                        )
                    )
                }
            }
            .bindAndCatch(to: stateRelay)
            .disposed(by: disposeBag)
    }

    public func refresh() {}
}
