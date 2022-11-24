// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

struct Event: Codable, Equatable {
    var originalTimestamp: Date
    let name: String
    var type: EventType
    let properties: [String: JSONValue]?

    init(title: String, properties: [String: Any?]?) {
        self.originalTimestamp = Date()
        self.name = title
        self.type = .event
        self.properties = properties?.compactMapValues(JSONValue.init)
    }
}
