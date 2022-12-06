// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import FeatureAuthenticationDomain
import RecaptchaEnterprise

class MockRecaptchaService: GoogleRecaptchaServiceAPI {

    func load() { }

    func verifyForSignup() -> AnyPublisher<String, GoogleRecaptchaError> {
        .just("")
    }

    func verifyForLogin() -> AnyPublisher<String, GoogleRecaptchaError> {
        .just("")
    }
}
