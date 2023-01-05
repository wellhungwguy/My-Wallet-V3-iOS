// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import Errors
import Foundation

public protocol SignUpCountriesClientAPI: AnyObject {
    var countries: AnyPublisher<[Country], NabuNetworkError> { get }
}
