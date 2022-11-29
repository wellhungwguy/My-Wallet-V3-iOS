// Copyright © Blockchain Luxembourg S.A. All rights reserved.

public struct Email: Decodable, Equatable {
    public let address: String
    public let verified: Bool

    private enum CodingKeys: String, CodingKey {
        case address = "email"
        case verified = "emailVerified"
    }

    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        self.address = try values.decode(String.self, forKey: .address)
        self.verified = try values.decode(Bool.self, forKey: .verified)
    }

    public init(address: String, verified: Bool) {
        self.address = address
        self.verified = verified
    }
}
