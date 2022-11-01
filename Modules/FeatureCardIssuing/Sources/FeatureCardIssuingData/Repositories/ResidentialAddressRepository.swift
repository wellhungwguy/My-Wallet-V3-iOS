// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import Errors
import FeatureCardIssuingDomain
import Foundation

final class ResidentialAddressRepository: AddressRepositoryAPI {

    private let client: ResidentialAddressClientAPI

    init(client: ResidentialAddressClientAPI) {
        self.client = client
    }

    func fetchAddress() -> AnyPublisher<Card.Address, NabuNetworkError> {
        client.fetchResidentialAddress()
    }

    func update(address: Card.Address) -> AnyPublisher<Card.Address, NabuNetworkError> {
        client.update(residentialAddress: address)
    }
}

final class ShippingAddressRepository: AddressRepositoryAPI {

    private var address = Card.Address(
        line1: nil,
        line2: nil,
        city: nil,
        postCode: nil,
        state: nil,
        country: nil
    )

    func fetchAddress() -> AnyPublisher<Card.Address, NabuNetworkError> {
        .just(address)
    }

    func update(address: Card.Address) -> AnyPublisher<Card.Address, NabuNetworkError> {
        self.address = address
        return .just(address)
    }
}
