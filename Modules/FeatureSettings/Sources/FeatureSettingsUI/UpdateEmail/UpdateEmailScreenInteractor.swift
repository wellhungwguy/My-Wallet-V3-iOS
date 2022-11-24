// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import ComposableArchitectureExtensions
import DIKit
import PlatformKit
import PlatformUIKit
import RxCocoa
import RxRelay
import RxSwift

final class UpdateEmailScreenInteractor {

    typealias BadgeItem = BadgeAsset.Value.Interaction.BadgeItem

    typealias EmailSettingsService = EmailSettingsServiceAPI &
        SettingsServiceAPI

    typealias InteractionState = LoadingState<InteractionModel>

    // MARK: - State

    struct Model {
        let badgeItem: BadgeItem
        let isEmailVerified: Bool
        let email: String

        init(badgeItem: BadgeItem, isEmailVerified: Bool = false, email: String) {
            self.badgeItem = badgeItem
            self.isEmailVerified = isEmailVerified
            self.email = email
        }
    }

    enum State {
        /// Interactor is ready for email entry
        case ready

        /// Email is being updated
        case updating

        /// Waiting for user to verify their email
        case waiting

        /// Email verified
        case verified

        /// Update failed
        case failed
    }

    struct InteractionModel {
        let values: Model
        let state: State
    }

    var cancelRelay = PublishRelay<Void>()
    var resendRelay = PublishRelay<Void>()
    var triggerRelay = PublishRelay<Void>()
    var contentRelay = BehaviorRelay<String>(value: "")
    var interactionState: Observable<InteractionState> {
        interactionModelRelay.asObservable()
    }

    private let verificationService: EmailVerificationServiceAPI
    private let emailSettingsService: EmailSettingsService
    private let interactionModelRelay = BehaviorRelay<InteractionState>(value: .loading)
    private let interactionStateRelay = BehaviorRelay<State>(value: .ready)
    private let disposeBag = DisposeBag()

    init(
        emailSettingsService: CompleteSettingsServiceAPI = resolve(),
        emailVerificationService: EmailVerificationServiceAPI = resolve()
    ) {
        self.emailSettingsService = emailSettingsService
        self.verificationService = emailVerificationService

        Observable.combineLatest(emailSettingsService.valueObservable, interactionStateRelay)
            .map {
                .init(
                    values: .init(
                        badgeItem: $0.0.isEmailVerified ? .verified : .unverified,
                        isEmailVerified: $0.0.isEmailVerified,
                        email: $0.0.email
                    ),
                    state: $0.1
                )
            }
            .map { .loaded(next: $0) }
            .startWith(.loading)
            .catchAndReturn(.loading)
            .bindAndCatch(to: interactionModelRelay)
            .disposed(by: disposeBag)

        cancelRelay
            .bindAndCatch(weak: self) { (self) in
                self.cancel()
            }
            .disposed(by: disposeBag)

        resendRelay
            .bindAndCatch(weak: self, onNext: { (self) in
                self.interactionStateRelay.accept(.updating)
                self.resendEmailVerification()
            })
            .disposed(by: disposeBag)

        triggerRelay
            .bindAndCatch(weak: self, onNext: { (self) in
                self.interactionStateRelay.accept(.updating)
                self.submit()
            })
            .disposed(by: disposeBag)
    }

    private func resendEmailVerification() {
        verificationService.cancel()
            .andThen(emailSettingsService.update(email: contentRelay.value, context: .settings))
            .andThen(update(state: .waiting))
            .andThen(verificationService.verifyEmail())
            .subscribe(
                onCompleted: { [weak self] in
                    self?.interactionStateRelay.accept(.ready)
                },
                onError: { [weak self] _ in
                    self?.interactionStateRelay.accept(.failed)
                }
            )
            .disposed(by: disposeBag)
    }

    private func cancel() {
        verificationService.cancel()
            .subscribe()
            .disposed(by: disposeBag)
    }

    private func submit() {
        emailSettingsService
            .update(email: contentRelay.value, context: .settings)
            .andThen(update(state: .waiting))
            .andThen(verificationService.verifyEmail())
            .subscribe(
                onCompleted: { [weak self] in
                    self?.interactionStateRelay.accept(.verified)
                },
                onError: { [weak self] _ in
                    self?.interactionStateRelay.accept(.failed)
                }
            )
            .disposed(by: disposeBag)
    }

    private func update(state: State) -> Completable {
        Completable.create { [weak self] observer -> Disposable in
            self?.interactionStateRelay.accept(state)
            observer(.completed)
            return Disposables.create()
        }
    }
}
