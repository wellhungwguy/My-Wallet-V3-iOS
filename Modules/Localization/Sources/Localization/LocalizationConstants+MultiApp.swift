// Copyright © Blockchain Luxembourg S.A. All rights reserved.

// swiftlint:disable all

import Foundation

public typealias MultiAppL10n = LocalizationConstants.MultiApp

extension LocalizationConstants {
    public enum MultiApp {
        public enum AppModeTitles {
            public static let trading = NSLocalizedString(
                "Trading",
                comment: "Trading title"
            )
            public static let defi = NSLocalizedString(
                "DeFi",
                comment: "DeFi title"
            )
        }

        public enum AppChrome {
            public static let totalBalance = NSLocalizedString(
                "Total Balance",
                comment: "Total Balance title"
            )
        }
    }
}
