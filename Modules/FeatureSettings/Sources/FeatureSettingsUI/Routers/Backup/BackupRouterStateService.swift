// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import PlatformKit
import PlatformUIKit
import RxCocoa
import RxRelay
import RxSwift
import ToolKit

final class BackupRouterStateService: BackupRouterStateServiceAPI {

    // MARK: - Types

    struct States {

        /// The actual state of the flow
        let current: State

        /// The previous states sorted chronologically
        let previous: [State]

        /// The starting state
        static var start: States {
            States(current: .start, previous: [])
        }

        /// Maps the instance of `States` into a new instance where the appended
        /// state is the current
        func states(byAppending state: State) -> States {
            States(
                current: state,
                previous: previous + [current]
            )
        }

        /// Maps the instance of `States` into a new instance where the last
        /// state is trimmed off.
        func statesByRemovingLast() -> States {
            States(
                current: previous.last ?? .end,
                previous: previous.dropLast()
            )
        }
    }

    // MARK: - Types

    enum State {
        case start

        /// The CTA for funds backup
        case backupFunds(PresentationType, BackupRouterEntry)

        /// The recovery phrase screen
        case recovery

        /// The verification screen
        case verification

        /// The verification has been skipped
        case skipped

        /// ~Fin~
        case end
    }

    enum Action {

        /// Procede to the next `State`
        case next(State)

        /// Return to the prior screen
        case previous

        /// Dismiss the screen
        case dismiss

        /// Dismiss the screen and the
        /// flow has been completed.
        case complete

        /// Dismiss the screen and the
        /// flow has been skipped.
        case skip
    }

    // MARK: - Properties

    var states: Observable<States> {
        statesRelay.asObservable()
    }

    var currentState: Observable<BackupRouterStateService.State> {
        states.map(\.current)
    }

    var action: Observable<Action> {
        actionRelay
            .observe(on: MainScheduler.instance)
    }

    let nextRelay = PublishRelay<Void>()
    let previousRelay = PublishRelay<Void>()

    private let statesRelay = BehaviorRelay<States>(value: .start)
    private let actionRelay = PublishRelay<Action>()
    private let entry: BackupRouterEntry

    private let disposeBag = DisposeBag()

    // MARK: - Setup

    init(entry: BackupRouterEntry) {
        self.entry = entry
        nextRelay
            .observe(on: MainScheduler.instance)
            .bindAndCatch(weak: self) { (self) in self.next() }
            .disposed(by: disposeBag)

        previousRelay
            .observe(on: MainScheduler.instance)
            .bindAndCatch(weak: self) { (self) in self.previous() }
            .disposed(by: disposeBag)
    }

    private func next() {
        let action: Action
        var state: State
        let states = statesRelay.value
        switch states.current {
        case .start:
            switch entry {
            case .custody:
                state = .backupFunds(.modalOverTopMost, entry)
            case .settings:
                state = .backupFunds(.navigationFromCurrent, entry)
            case .defiIntroScreen:
                state = .backupFunds(.modalOverTopMost, entry)
            }
            action = .next(state)
        case .backupFunds:
            state = .recovery
            action = .next(state)
        case .recovery:
            state = .verification
            action = .next(state)
        case .verification:
            state = .end
            action = .complete
        case .skipped:
            state = .skipped
            action = .skip
        case .end:
            state = .end
            action = .complete
        }
        let nextStates = states.states(byAppending: state)
        apply(action: action, states: nextStates)
    }

    private func previous() {
        let states = statesRelay.value.statesByRemovingLast()
        let action: Action
        switch states.current {
        case .start:
            action = .skip
        case .end:
            action = .complete
        default:
            action = .previous
        }
        apply(action: action, states: states)
    }

    private func apply(action: Action, states: States) {
        actionRelay.accept(action)
        statesRelay.accept(states)
    }
}
