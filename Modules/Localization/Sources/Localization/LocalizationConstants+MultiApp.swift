// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

extension LocalizationConstants {
    public enum MultiApp {
        public enum AppChrome {}
        public enum AllAssets {
            public enum Filter {}
        }
    }
}

extension LocalizationConstants.MultiApp {
    public static let trading = NSLocalizedString(
        "Trading",
        comment: "Trading title"
    )
    public static let pkw = NSLocalizedString(
        "DeFi",
        comment: "DeFi title"
    )
}

extension LocalizationConstants.MultiApp.AppChrome {
    public static let totalBalance = NSLocalizedString(
        "Total Balance",
        comment: "Total Balance title"
    )
}

extension LocalizationConstants.MultiApp.AllAssets {
    public static let title = NSLocalizedString(
        "All assets",
        comment: "All assets"
    )

    public static let searchPlaceholder = NSLocalizedString(
        "Search coin",
        comment: "Search coin"
    )

    public static let cancelButton = NSLocalizedString(
        "Cancel",
        comment: "Cancel"
    )

    public static var noResults = NSLocalizedString(
        "😞 No results",
        comment: "😞 No results"
    )
}

extension LocalizationConstants.MultiApp.AllAssets.Filter {
    public static let title = NSLocalizedString(
        "Filter Assets",
        comment: "Filter Assets"
    )

    public static let showSmallBalancesLabel = NSLocalizedString(
        "Show small balances",
        comment: "Show small balances"
    )

    public static let showButton = NSLocalizedString(
        "Show",
        comment: "Show"
    )

    public static var resetButton = NSLocalizedString(
        "Reset",
        comment: "Reset"
    )
}
