// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import Errors
import Foundation

final class AddressSearchService: AddressSearchServiceAPI {

    private let repository: AddressSearchRepositoryAPI

    init(repository: AddressSearchRepositoryAPI) {
        self.repository = repository
    }

    func fetchAddresses(
        searchText: String,
        containerId: String?,
        countryCode: String,
        sateCode: String?
    ) -> AnyPublisher<[AddressSearchResult], AddressSearchServiceError> {
        repository.fetchAddresses(
            searchText: searchText,
            containerId: containerId,
            countryCode: countryCode,
            sateCode: sateCode
        )
        .mapError(AddressSearchServiceError.network)
        .eraseToAnyPublisher()
    }

    func fetchAddress(
        addressId: String
    ) -> AnyPublisher<AddressDetailsSearchResult, AddressSearchServiceError> {
        repository.fetchAddress(addressId: addressId)
            .mapError(AddressSearchServiceError.network)
            .eraseToAnyPublisher()
    }
}
