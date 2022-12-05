// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

public struct PrefillInfo: Equatable {
    public let firstName: String?
    public let lastName: String?
    public let addresses: [Address]
    public let dateOfBirth: Date?
    public let phone: String?

    public init(
        firstName: String?,
        lastName: String?,
        addresses: [Address],
        dateOfBirth: Date?,
        phone: String?
    ) {
        self.firstName = firstName
        self.lastName = lastName
        self.addresses = addresses
        self.dateOfBirth = dateOfBirth
        self.phone = phone
    }
}

extension PrefillInfo {
    public func validAddresses(country: String?, state: String?) -> [Address] {
        guard let country = country, country == "US", let state = state else { return addresses }
        return addresses.filter { $0.state == state }
    }
}
