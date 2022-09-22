// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import FeatureAddressSearchDomain
import Foundation

extension Address {
    static func sample(
        line1: String? = "line 1",
        line2: String? = "line 2",
        city: String? = "London",
        postCode: String? = "E14 6GF",
        state: String? = nil,
        country: String? = "GB"
    ) -> Self {
        Address(
            line1: line1,
            line2: line2,
            city: city,
            postCode: postCode,
            state: state,
            country: country
        )
    }
}
