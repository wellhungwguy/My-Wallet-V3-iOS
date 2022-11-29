// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

func interactiveExperienceAvailable() -> Bool {
    if #available(iOS 16.0, *) {
        return true
    }
    return false
}
