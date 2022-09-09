// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import FeatureAddressSearchDomain
import Foundation

extension AddressSearchResult {
    static func sample(
        addressId: String? = "addressId",
        text: String? = "line 1 line 2",
        type: String? = AddressSearchResult.AddressType.address.rawValue,
        highlight: String? = nil,
        description: String? = "London E14 6GF"
    ) -> Self {
        AddressSearchResult(
            addressId: addressId,
            text: text,
            type: type,
            highlight: highlight,
            description: description
        )
    }
}
