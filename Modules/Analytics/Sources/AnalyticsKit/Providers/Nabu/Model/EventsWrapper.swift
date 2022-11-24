// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

struct EventsWrapper: Encodable {
    let id: String?
    let platform: Platform
    let context: Context
    let events: [Event]
    let device = "APP-iOS"

    init(contextProvider: ContextProviderAPI, events: [Event], platform: Platform) {
        self.id = contextProvider.anonymousId
        self.context = contextProvider.context
        self.events = events
        self.platform = platform
    }
}
