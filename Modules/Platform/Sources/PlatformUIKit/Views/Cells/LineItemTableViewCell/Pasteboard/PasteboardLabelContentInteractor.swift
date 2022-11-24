// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import PlatformKit
import RxRelay
import RxSwift

/// A protocol for `UILabels` whose content can be copied to the clipboard.
public protocol PasteboardLabelContentInteracting: LabelContentInteracting {
    var pasteboardTriggerRelay: PublishRelay<Void> { get }
    var isPasteboarding: BehaviorRelay<Bool> { get }
}

public final class PasteboardLabelContentInteractor: PasteboardLabelContentInteracting {

    // MARK: - Types

    public typealias InteractionState = LabelContent.State.Interaction

    /// A `PublishRelay` that triggers the applying of the `interactionText`.
    /// After the `interactionDuration` has passed (in seconds) the original
    /// text will be shown.
    public var pasteboardTriggerRelay = PublishRelay<Void>()

    /// Returns whether or not the pasteboarding effect is still visible.
    /// Effect lasts as long as the `interactionDuration` provided.
    public var isPasteboarding = BehaviorRelay(value: false)

    public let stateRelay: BehaviorRelay<InteractionState>
    public var state: Observable<InteractionState> {
        stateRelay.asObservable()
    }

    // Relay for holding the actual values that populates the label.
    private let originalValueStateRelay: BehaviorRelay<InteractionState>
    var originalValueState: Observable<InteractionState> {
        originalValueStateRelay.asObservable()
    }

    // MARK: - Private Accessors

    private let disposeBag = DisposeBag()

    // MARK: - Setup

    init(text: String, interactionText: String, interactionDuration: Int) {

        let originalValue: InteractionState = .loaded(next: .init(text: text))
        self.stateRelay = .init(value: originalValue)
        self.originalValueStateRelay = .init(value: originalValue)

        stateRelay
            .filter { $0.value?.text != interactionText }
            .bindAndCatch(to: originalValueStateRelay)
            .disposed(by: disposeBag)

        pasteboardTriggerRelay
            .map { .loaded(next: .init(text: interactionText)) }
            .bindAndCatch(to: stateRelay)
            .disposed(by: disposeBag)

        pasteboardTriggerRelay
            .debounce(
                .seconds(interactionDuration),
                scheduler: ConcurrentDispatchQueueScheduler(qos: .userInitiated)
            )
            .withLatestFrom(originalValueState)
            .bindAndCatch(to: stateRelay)
            .disposed(by: disposeBag)

        stateRelay
            .compactMap { $0.value?.text }
            .map { $0 == interactionText }
            .bindAndCatch(to: isPasteboarding)
            .disposed(by: disposeBag)
    }
}
