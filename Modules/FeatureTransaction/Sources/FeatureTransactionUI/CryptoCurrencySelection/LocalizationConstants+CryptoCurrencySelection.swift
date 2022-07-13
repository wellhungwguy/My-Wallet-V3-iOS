// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Localization

extension LocalizationConstants {
    enum CryptoCurrencySelection {
        static let errorTitle = NSLocalizedString(
            "Something went wrong",
            comment: "Title for list loading error"
        )

        static let errorButtonTitle = NSLocalizedString(
            "Retry",
            comment: "Retry CTA button title"
        )

        static let errorDescription = NSLocalizedString(
            "Couldn't load a list of available cryptocurrencies: %@",
            comment: "Description for list loading error"
        )

        static let title = NSLocalizedString(
            "Want to Buy Crypto?",
            comment: "Buy list header title"
        )

        static let description = NSLocalizedString(
            "Select the crypto you want to buy and link a debit or credit card.",
            comment: "Buy list header description"
        )

        static let searchPlaceholder = NSLocalizedString(
            "Search",
            comment: "Search text field placeholder"
        )

        static let emptyListTitle = NSLocalizedString(
            "No purchasable pairs found",
            comment: "Buy empty list title"
        )

        static let retryButtonTitle = NSLocalizedString(
            "Retry",
            comment: "Retry list loading button title"
        )

        static let notNowButtonTitle = NSLocalizedString(
            "Not Now",
            comment: "Not now button title"
        )
    }

    enum MajorProductBlocked {
        public static let title = NSLocalizedString(
            "Trading Restricted",
            comment: "EU_5_SANCTION card title."
        )

        public static let ctaButtonLearnMore = NSLocalizedString(
            "Learn More",
            comment: "EU_5_SANCTION card CTA button title."
        )

        public static let defaultMessage = NSLocalizedString(
            "Default message for inelibility",
            comment: "This operation cannot be performed at this time. Please try again later."
        )
    }
}
