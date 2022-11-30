// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainComponentLibrary
import BlockchainNamespace
import Localization
import SwiftUI

extension AppMode {
    var title: String {
        switch self {
        case .trading:
            return LocalizationConstants.SuperApp.trading
        case .pkw:
            return LocalizationConstants.SuperApp.pkw
        case .universal:
            return ""
        }
    }

    var isTrading: Bool {
        self == .trading
    }

    var isDefi: Bool {
        self == .pkw
    }

    var backgroundGradient: [Color] {
        switch self {
        case .trading:
            // TODO: Might worth checking into dark mode gradient colors
            return [Color(hex: "#FF0297"), Color(hex: "#AE22AD")]
        case .pkw:
            return [Color(hex: "#6B39BD"), Color(hex: "#2878D4")]
        case .universal:
            return []
        }
    }
}
