// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

public struct ConfirmInfo: Equatable {
    public let firstName: String
    public let lastName: String
    public let address: Address
    public let dateOfBirth: Date
    public let phone: String

    public init(
        firstName: String,
        lastName: String,
        address: Address,
        dateOfBirth: Date,
        phone: String
    ) {
        self.firstName = firstName
        self.lastName = lastName
        self.address = address
        self.dateOfBirth = dateOfBirth
        self.phone = phone
    }
}
