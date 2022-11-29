// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import Errors
import Foundation

public protocol AddressRepositoryAPI {

    func fetchAddress() -> AnyPublisher<Card.Address, NabuNetworkError>
    func update(address: Card.Address) -> AnyPublisher<Card.Address, NabuNetworkError>
}
