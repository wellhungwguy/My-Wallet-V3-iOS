// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

public struct AddressDetailsSearchResult: Codable, Equatable {

    enum CodingKeys: String, CodingKey {
        case addressId = "id"
        case line1
        case line2
        case line3
        case line4
        case line5
        case street
        case buildingNumber
        case city
        case postCode = "postalCode"
        case state = "provinceCode"
        case country = "countryIso2"
        case label
    }

    public let addressId: String?
    public let line1: String?
    public let line2: String?
    public let line3: String?
    public let line4: String?
    public let line5: String?
    public let street: String?
    public let buildingNumber: String?
    public let city: String?
    public let postCode: String?
    public let state: String?
    /// Country code in ISO-2
    public let country: String?
    public let label: String?

    public init(
        addressId: String?,
        line1: String?,
        line2: String? = nil,
        line3: String? = nil,
        line4: String? = nil,
        line5: String? = nil,
        street: String?,
        buildingNumber: String?,
        city: String?,
        postCode: String?,
        state: String?,
        /// Country code in ISO-2
        country: String?,
        label: String?
    ) {
        self.addressId = addressId
        self.line1 = line1
        self.line2 = line2
        self.line3 = line3
        self.line4 = line4
        self.line5 = line5
        self.street = street
        self.buildingNumber = buildingNumber
        self.city = city
        self.postCode = postCode
        self.state = state
        self.country = country
        self.label = label
    }
}
