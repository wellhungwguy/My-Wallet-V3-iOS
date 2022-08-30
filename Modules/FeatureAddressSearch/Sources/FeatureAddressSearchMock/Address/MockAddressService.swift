// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import FeatureAddressSearchDomain

class MockAddressService: AddressServiceAPI {
    func fetchAddress() -> AnyPublisher<Address?, AddressServiceError> {
        .just(.sample())
    }
    func save(address: Address) -> AnyPublisher<Address, AddressServiceError> {
        .just(address)
    }
}
