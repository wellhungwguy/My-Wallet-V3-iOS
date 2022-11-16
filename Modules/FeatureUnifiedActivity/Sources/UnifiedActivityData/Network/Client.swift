// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import Foundation
import NetworkKit
import UnifiedActivityDomain

struct AuthDataPayload: Encodable {
    let guidHash: String
    let sharedKeyHash: String
}

struct ActivityRequest: Encodable {

    struct Parameters: Encodable {
        let timezoneIana: String
        let fiatCurrency: String
        let acceptLanguage: String
    }

    let action: String = "subscribe"
    let channel: Channel = .activity
    let auth: AuthDataPayload
    let params: Parameters
}
