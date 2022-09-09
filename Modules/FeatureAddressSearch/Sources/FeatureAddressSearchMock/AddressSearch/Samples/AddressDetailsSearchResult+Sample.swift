// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import FeatureAddressSearchDomain
import Foundation

extension AddressDetailsSearchResult {
    static func sample(
        addressId: String? = "addressId",
        line1: String? = "line 1",
        line2: String? = "line 2",
        line3: String? = nil,
        line4: String? = nil,
        line5: String? = nil,
        street: String? = "street 3",
        buildingNumber: String? = nil,
        city: String? = "London",
        postCode: String? = "E14 6GF",
        state: String? = nil,
        country: String? = "GB",
        label: String? = nil
    ) -> Self {
        AddressDetailsSearchResult(
            addressId: addressId,
            line1: line1,
            line2: line2,
            line3: line3,
            line4: line4,
            line5: line5,
            street: street,
            buildingNumber: buildingNumber,
            city: city,
            postCode: postCode,
            state: state,
            country: country,
            label: label
        )
    }
}
