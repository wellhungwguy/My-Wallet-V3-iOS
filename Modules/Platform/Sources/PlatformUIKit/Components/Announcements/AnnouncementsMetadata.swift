// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import PlatformKit

public struct AnnouncementsMetadata: Decodable {

    enum CodingKeys: String, CodingKey {
        case interval
        case order
    }

    public let order: [AnnouncementType]
    public let interval: TimeInterval

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let order = try container.decode([String].self, forKey: .order)
        self.order = order.compactMap { AnnouncementType(rawValue: $0) }
        let days = try container.decode(Int.self, forKey: .interval)
        self.interval = TimeInterval(days) * .day
    }
}
