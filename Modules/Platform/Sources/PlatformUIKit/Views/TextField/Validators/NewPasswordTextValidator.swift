// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import FeatureAuthenticationDomain
import PlatformKit
import RxRelay
import RxSwift
import Zxcvbn

/// Password text validator
final class NewPasswordTextValidator: NewPasswordValidating {

    // MARK: - TextValidating Properties

    let valueRelay = BehaviorRelay<String>(value: "")

    var validationState: Observable<TextValidationState> {
        validationStateRelay.asObservable()
    }

    // MARK: - NewPasswordValidating Properties

    var score: Observable<PasswordValidationScore> {
        scoreRelay.asObservable()
    }

    // MARK: - Private Properties

    private let scoreRelay = BehaviorRelay<PasswordValidationScore>(value: .weak)
    private let validationStateRelay = BehaviorRelay<TextValidationState>(value: .invalid(reason: nil))
    private let validator = DBZxcvbn()
    private let disposeBag = DisposeBag()

    init() {
        valueRelay
            .map(weak: self) { (self, password) -> (DBResult?, String) in
                (self.validator.passwordStrength(password), password)
            }
            .map { (result: DBResult?, password) -> PasswordValidationScore in
                guard let result else { return .none }
                return PasswordValidationScore(
                    zxcvbnScore: result.score,
                    password: password
                )
            }
            // Ending up in an error state is fine (probably object deallocated)
            .catchAndReturn(.weak)
            .bindAndCatch(to: scoreRelay)
            .disposed(by: disposeBag)

        scoreRelay
            .map(\.isValid)
            .map { $0 ? .valid : .invalid(reason: nil) }
            .bindAndCatch(to: validationStateRelay)
            .disposed(by: disposeBag)
    }
}
