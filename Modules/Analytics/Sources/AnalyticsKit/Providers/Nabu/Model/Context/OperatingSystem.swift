// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

struct OperatingSystem: Encodable {
    let name: String
    let version: String
}

#if canImport(UIKit)
import UIKit

extension OperatingSystem {

    init(device: UIDevice = UIDevice.current) {
        self.name = device.systemName
        self.version = device.systemVersion
    }
}

#endif

#if canImport(AppKit)
import AppKit

extension OperatingSystem {

    init() {
        self.name = "macos"
        self.version = ProcessInfo.processInfo.operatingSystemVersionString
    }
}

#endif
