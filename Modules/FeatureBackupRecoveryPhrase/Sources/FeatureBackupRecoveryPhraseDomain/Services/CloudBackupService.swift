// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation
import PlatformKit
import ToolKit

public class CloudBackupService: CloudBackupConfiguring {
    enum Keys: String {
        case cloudBackupEnabled
    }

     private var defaults: CacheSuite

    public init(defaults: CacheSuite) {
        self.defaults = defaults
    }

    public var cloudBackupEnabled: Bool {
        get {
            defaults.bool(forKey: Keys.cloudBackupEnabled.rawValue)
        }
        set {
            defaults.set(newValue, forKey: Keys.cloudBackupEnabled.rawValue)
        }
    }
}
