// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

public enum DetailType: Equatable, Decodable {

    case groupedItems(ActivityDetail.GroupedItems)

    enum CodingKeys: CodingKey {
        case type
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let name = try container.decode(String.self, forKey: .type)
        switch name {
        case "GROUPED_ITEMS":
            self = .groupedItems(try ActivityDetail.GroupedItems(from: decoder))
        default:
            throw DecodingError.dataCorruptedError(
                forKey: .type,
                in: container,
                debugDescription: "Unkown type \(name)"
            )
        }
    }
}
