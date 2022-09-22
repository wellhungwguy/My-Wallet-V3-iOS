// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

public struct AddressSearchResult: Codable, Equatable {

    public enum AddressType: String {
        case address = "Address"
    }

    enum CodingKeys: String, CodingKey {
        case addressId = "id"
        case text
        case type
        case highlight
        case description
    }

    public let addressId: String?
    public let text: String?
    public let type: String?
    public let highlight: String?
    public let description: String?

    public init(
        addressId: String?,
        text: String?,
        type: String?,
        highlight: String?,
        description: String?
    ) {
        self.addressId = addressId
        self.text = text
        self.type = type
        self.highlight = highlight
        self.description = description
    }
}

extension AddressSearchResult {
    public var isAddressType: Bool { type == AddressSearchResult.AddressType.address.rawValue }
}
