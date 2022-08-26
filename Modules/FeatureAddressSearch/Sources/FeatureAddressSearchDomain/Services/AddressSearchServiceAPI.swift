// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import Errors
import Foundation

public enum AddressSearchServiceError: Error, Equatable {
    case network(Nabu.Error)
}

public protocol AddressSearchServiceAPI {

    func fetchAddresses(
        searchText: String,
        containerId: String?,
        countryCode: String,
        sateCode: String?
    ) -> AnyPublisher<[AddressSearchResult], AddressSearchServiceError>

    func fetchAddress(
        addressId: String
    ) -> AnyPublisher<AddressDetailsSearchResult, AddressSearchServiceError>
}
