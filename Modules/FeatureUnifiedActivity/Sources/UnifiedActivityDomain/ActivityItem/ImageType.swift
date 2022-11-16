// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

public enum ImageType: Equatable, Decodable {
    case smallTag(ActivityItem.ImageSmallTag)

    enum CodingKeys: CodingKey {
        case type
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let name = try container.decode(String.self, forKey: .type)
        switch name {
        case "SMALL_TAG":
            self = .smallTag(try ActivityItem.ImageSmallTag(from: decoder))
        default:
            throw DecodingError.dataCorruptedError(
                forKey: .type,
                in: container,
                debugDescription: "Unkown type \(name)"
            )
        }
    }
}
