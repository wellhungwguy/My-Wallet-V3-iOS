// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import Errors
import Foundation

final class AddressService: CardIssuingAddressServiceAPI {

    private let repository: AddressRepositoryAPI

    init(repository: AddressRepositoryAPI) {
        self.repository = repository
    }
}

// MARK: - CardIssuingAddressServiceAPI

extension AddressService {
    func fetchAddress() -> AnyPublisher<Card.Address, NabuNetworkError> {
        repository.fetchAddress()
    }

    func update(address: Card.Address) -> AnyPublisher<Card.Address, NabuNetworkError> {
        repository.update(address: address)
    }
}
