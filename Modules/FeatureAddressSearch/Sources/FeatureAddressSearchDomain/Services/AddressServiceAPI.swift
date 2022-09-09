// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import Errors
import Foundation

public enum AddressServiceError: Error, Equatable {
    case network(Nabu.Error)
}

public protocol AddressServiceAPI {

    func fetchAddress() -> AnyPublisher<Address?, AddressServiceError>
    func save(address: Address) -> AnyPublisher<Address, AddressServiceError>
}
