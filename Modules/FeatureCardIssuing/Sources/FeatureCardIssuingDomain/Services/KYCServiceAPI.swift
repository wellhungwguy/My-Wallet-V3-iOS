// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import Errors
import Foundation

public protocol KYCServiceAPI {
    func update(address: Card.Address?, ssn: String?) -> AnyPublisher<KYC, NabuNetworkError>
    func fetch() -> AnyPublisher<KYC, NabuNetworkError>
}
