// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

public struct PrefillInfoResponse: Decodable {

    let fullName: String?
    let dateOfBirth: Date?
    let phone: String?

    enum CodingKeys: String, CodingKey {
        case fullName
        case birthday = "dob"
        case phone
    }

    public init(fullName: String, phone: String, dateOfBirth: Date) {
        self.fullName = fullName
        self.phone = phone
        self.dateOfBirth = dateOfBirth
    }

    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        self.fullName = try values.decodeIfPresent(String.self, forKey: .fullName)
        self.dateOfBirth = (try values.decodeIfPresent(String.self, forKey: .birthday))
            .flatMap { DateFormatter.birthday.date(from: $0) }
        self.phone = try values.decodeIfPresent(String.self, forKey: .phone)
    }
}
