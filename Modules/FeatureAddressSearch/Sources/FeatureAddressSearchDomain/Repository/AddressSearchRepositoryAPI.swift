// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import Errors

public protocol AddressSearchRepositoryAPI {

    func fetchAddresses(
        searchText: String,
        containerId: String?,
        countryCode: String,
        sateCode: String?
    ) -> AnyPublisher<[AddressSearchResult], Nabu.Error>

    func fetchAddress(
        addressId: String
    ) -> AnyPublisher<AddressDetailsSearchResult, Nabu.Error>
}
