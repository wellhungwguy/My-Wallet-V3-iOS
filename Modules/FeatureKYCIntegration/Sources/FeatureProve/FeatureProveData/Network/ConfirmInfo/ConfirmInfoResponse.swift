// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import FeatureProveDomain
import Foundation

public struct ConfirmInfoResponse: Decodable {

    let firstName: String
    let lastName: String
    let address: Address
    let dateOfBirth: Date?
    let phone: String

    enum CodingKeys: String, CodingKey {
        case firstName
        case lastName
        case address
        case birthday = "dob"
        case phone
    }

    public init(
        firstName: String,
        lastName: String,
        address: Address,
        phone: String,
        dateOfBirth: Date
    ) {
        self.firstName = firstName
        self.lastName = lastName
        self.address = address
        self.phone = phone
        self.dateOfBirth = dateOfBirth
    }

    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        self.firstName = try values.decode(String.self, forKey: .firstName)
        self.lastName = try values.decode(String.self, forKey: .lastName)
        self.address = try values.decode(Address.self, forKey: .address)
        self.dateOfBirth = (try values.decodeIfPresent(String.self, forKey: .birthday))
            .flatMap { DateFormatter.birthday.date(from: $0) }
        self.phone = try values.decode(String.self, forKey: .phone)
    }
}
