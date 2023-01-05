// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
@testable import FeatureAuthenticationDomain

public class MockSignUpCountriesService: SignUpCountriesServiceAPI {

    public init() {}

    public var countries: AnyPublisher<[Country], Error> {
        .empty()
    }
}
