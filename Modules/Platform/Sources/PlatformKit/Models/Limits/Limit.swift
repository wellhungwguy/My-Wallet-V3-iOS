// Copyright © Blockchain Luxembourg S.A. All rights reserved.

public struct Limit: Decodable {
    public let limit: Decimal
    public let available: Decimal
    public let used: Decimal

    enum CodingKeys: String, CodingKey {
        case limit
        case available
        case used
    }

    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        self.limit = try values.decodeIfPresentDecimalFromString(forKey: .limit) ?? 0
        self.available = try values.decodeIfPresentDecimalFromString(forKey: .available) ?? 0
        self.used = try values.decodeIfPresentDecimalFromString(forKey: .used) ?? 0
    }
}
