// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Localization

extension LocalizationConstants {
    enum Checkout {
        enum Label {
            static let from = NSLocalizedString(
                "From",
                comment: "From label for swap source"
            )
            static let to = NSLocalizedString(
                "To",
                comment: "To label for swap destination"
            )
            static let exchangeRate = NSLocalizedString(
                "Exchange Rate",
                comment: "Exchange Rate label title"
            )
            static let exchangeRateDisclaimer = NSLocalizedString(
                "The exchange rate is the best price available for %@ in terms of 1 %@. [Learn more]()",
                comment: "Exchange rate disclaimer"
            )
            static let networkFees = NSLocalizedString(
                "Network Fees",
                comment: "Network fees title label"
            )
            static let assetNetworkFees = NSLocalizedString(
                "%@ Network Fees",
                comment: "Asset network fees label"
            )
            static let noNetworkFee = NSLocalizedString(
                "Free",
                comment: "No network fee label"
            )
            static let and = NSLocalizedString(
                "and",
                comment: "And"
            )
            static let feesDisclaimer = NSLocalizedString(
                "Network fees are set by the %@ and %@ network. [Learn more about fees]()",
                comment: ""
            )
            static let refundDisclaimer = NSLocalizedString(
                "Final amount may change due to market activity. By approving this Swap you agree to Blockchain.com’s [Refund Policy]().",
                comment: "Refund disclaimer"
            )
            static let countdown = NSLocalizedString(
                "New Quote in: ",
                comment: "Quote time to live coundown label."
            )
        }

        enum Button {
            static let confirmSwap = NSLocalizedString(
                "Swap %@ for %@",
                comment: "Swap confirmation button title"
            )
        }
    }
}
