// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import Foundation
import NetworkKit
import UnifiedActivityDomain

enum Channel: String, Codable {
    case activity
    case heartbeat
}

enum EventType: String, Codable {
    case snapshot
    case update
}

enum WebSocketEvent: Decodable, Equatable {
    case heartbeat
    case snapshot(Payload)
    case update(Payload)

    private enum CodingKeys: String, CodingKey {
        case channel
        case event
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let channel = try container.decode(Channel.self, forKey: .channel)
        let event = try container.decode(EventType.self, forKey: .event)

        switch channel {
        case .heartbeat:
            self = .heartbeat
        case .activity:
            switch event {
            case .update:
                self = .update(try Payload(from: decoder))
            case .snapshot:
                self = .snapshot(try Payload(from: decoder))
            }
        }
    }
}

extension WebSocketEvent {
    struct Payload: Equatable, Decodable {
        let seqnum: Int
        let event: EventType
        let channel: Channel
        let data: PayloadData
    }

    struct PayloadData: Equatable, Decodable {
        let network: String
        let pubKey: String
        let activity: [ActivityEntry]
    }
}
