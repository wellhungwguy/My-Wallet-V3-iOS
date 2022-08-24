// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import Errors
import Foundation

final class ResidentialAddressService: ResidentialAddressServiceAPI {

    private let repository: ResidentialAddressRepositoryAPI

    init(repository: ResidentialAddressRepositoryAPI) {
        self.repository = repository
    }
}

// MARK: - ResidentialAddressServiceAPI
extension ResidentialAddressService {
    func fetchResidentialAddress() -> AnyPublisher<Card.Address, NabuNetworkError> {
        repository.fetchResidentialAddress()
    }

    func update(residentialAddress: Card.Address) -> AnyPublisher<Card.Address, NabuNetworkError> {
        repository.update(residentialAddress: residentialAddress)
    }
}
