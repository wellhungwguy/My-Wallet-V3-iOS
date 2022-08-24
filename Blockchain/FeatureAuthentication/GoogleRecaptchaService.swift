// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import DIKit
import FeatureAuthenticationDomain

final class GoogleRecaptchaService: GoogleRecaptchaServiceAPI {

    private let recaptchaClient: RecaptchaClient

    init(recaptchaClient: RecaptchaClient = resolve()) {
        self.recaptchaClient = recaptchaClient
    }

    func verifyForLogin() -> AnyPublisher<String, GoogleRecaptchaError> {
        verify(action: .login)
    }

    func verifyForSignup() -> AnyPublisher<String, GoogleRecaptchaError> {
        verify(action: .signup)
    }

    private func verify(action: RecaptchaActionType) -> AnyPublisher<String, GoogleRecaptchaError> {
        Deferred { [recaptchaClient] in
            Future { promise in
                recaptchaClient
                    .execute(RecaptchaAction(action: action)) { token, error in
                        if token == nil, error == nil {
                            promise(.failure(GoogleRecaptchaError.unknownError))
                        }
                        if let recaptchaToken = token {
                            promise(.success(recaptchaToken.recaptchaToken))
                        } else {
                            promise(.failure(GoogleRecaptchaError.missingRecaptchaTokenError))
                        }
                        if let recaptchaError = error {
                            promise(.failure(GoogleRecaptchaError.rcaRecaptchaError(recaptchaError.errorMessage)))
                        }
                    }
            }
        }
        .eraseToAnyPublisher()
    }
}
