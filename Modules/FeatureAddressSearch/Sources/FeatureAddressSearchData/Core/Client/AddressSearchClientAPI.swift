// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import Errors
import FeatureAddressSearchDomain
import Foundation
import NetworkKit

protocol AddressSearchClientAPI {

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
