// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import FeatureAuthenticationDomain
import RxSwift

public protocol NewPasswordValidating: TextValidating {
    var score: Observable<PasswordValidationScore> { get }
}
