// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

public enum ItemType: Equatable, Decodable {

    case stackView(ActivityItem.StackView)
    case text(ActivityItem.Text)
    case button(ActivityItem.Button)
    case badge(ActivityItem.Badge)

    enum CodingKeys: CodingKey {
        case type
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let name = try container.decode(String.self, forKey: .type)
        switch name {
        case "STACK_VIEW":
            self = .stackView(try ActivityItem.StackView(from: decoder))
        case "TEXT":
            self = .text(try ActivityItem.Text(from: decoder))
        case "BUTTON":
            self = .button(try ActivityItem.Button(from: decoder))
        case "BADGE":
            self = .badge(try ActivityItem.Badge(from: decoder))
        default:
            throw DecodingError.dataCorruptedError(
                forKey: .type,
                in: container,
                debugDescription: "Unkown type \(name)"
            )
        }
    }
}
