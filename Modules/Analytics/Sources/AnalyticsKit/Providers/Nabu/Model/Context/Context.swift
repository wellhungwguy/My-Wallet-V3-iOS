// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

struct Context: Encodable {
    let app: App
    let device: Device
    let os: OperatingSystem
    let locale: String
    let screen: Screen
    let traits: [String: String]
    let timezone: String?
}
