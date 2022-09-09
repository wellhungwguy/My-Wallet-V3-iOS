// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import FeatureAddressSearchDomain

class MockAddressSearchService: AddressSearchServiceAPI {
    func fetchAddresses(
        searchText: String,
        containerId: String?,
        countryCode: String,
        sateCode: String?
    ) -> AnyPublisher<[AddressSearchResult], AddressSearchServiceError> {
        .just([.sample()])
    }

    func fetchAddress(
        addressId: String
    ) -> AnyPublisher<AddressDetailsSearchResult, AddressSearchServiceError> {
        .just(.sample())
    }
}
