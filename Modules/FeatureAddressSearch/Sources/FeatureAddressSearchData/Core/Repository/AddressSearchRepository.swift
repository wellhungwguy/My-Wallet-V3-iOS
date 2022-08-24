// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import Errors
import FeatureAddressSearchDomain
import Foundation

final class AddressSearchRepository: AddressSearchRepositoryAPI {

    private let client: AddressSearchClientAPI

    init(client: AddressSearchClientAPI) {
        self.client = client
    }

    func fetchAddresses(
        searchText: String,
        containerId: String?,
        countryCode: String
    ) -> AnyPublisher<[AddressSearchResult], Nabu.Error> {
        client
            .fetchAddresses(
                searchText: searchText,
                containerId: containerId,
                countryCode: countryCode
            )
    }

    func fetchAddress(
        addressId: String
    ) -> AnyPublisher<AddressDetailsSearchResult, Nabu.Error> {
        client
            .fetchAddress(addressId: addressId)
    }
}
