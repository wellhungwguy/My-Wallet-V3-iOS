// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Localization

extension LocalizationConstants {
    enum Checkout {
        enum Label {
            static let checkout = NSLocalizedString(
                "Checkout",
                comment: "Checkout title"
            )
            static let from = NSLocalizedString(
                "From",
                comment: "From label for swap source"
            )
            static let to = NSLocalizedString(
                "To",
                comment: "To label for swap destination"
            )
            static let purchase = NSLocalizedString(
                "Purchase",
                comment: "Purchase label for buy destination"
            )
            static let total = NSLocalizedString(
                "Total",
                comment: "Total label for buy destination"
            )
            static let blockchainFee = NSLocalizedString(
                "Blockchain.com Fee",
                comment: "Blockchain.com Fee label"
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
            static let free = NSLocalizedString(
                "Free",
                comment: "No fee label"
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
            static let custodialFeeDisclaimer = NSLocalizedString(
                "Blockchain.com requires a fee when using this payment method.",
                comment: ""
            )
            static let refundDisclaimer = NSLocalizedString(
                "Final amount may change due to market activity. By approving this Swap you agree to Blockchain.com’s [Refund Policy]().",
                comment: "Refund disclaimer"
            )
            static let indicativeDisclaimer = NSLocalizedString(
                "Final amount may change due to market activity.",
                comment: "Final amount may change due to market activity."
            )
            static let termsOfService = NSLocalizedString(
                "By approving this transaction you agree to Blockchain’s [Terms of Service](http://blockchain.com) and its return, refund and cancellation policy.",
                comment: "Refund disclaimer"
            )
            static let countdown = NSLocalizedString(
                "New Quote in: ",
                comment: "Quote time to live coundown label."
            )
            static let paymentMethod = NSLocalizedString(
                "Payment Method",
                comment: "From label for swap source"
            )
            static func price(_ code: String) -> String {
                NSLocalizedString("%@ Price", comment: "").interpolating(code)
            }

            static let priceDisclaimer = NSLocalizedString(
                "Blockchain.com provides the best market price we receive and applies a spread.",
                comment: ""
            )
        }

        enum Button {
            static func buy(_ code: String) -> String {
                NSLocalizedString("Buy %@", comment: "").interpolating(code)
            }

            static let confirmSwap = NSLocalizedString(
                "Swap %@ for %@",
                comment: "Swap confirmation button title"
            )
            static let learnMore = NSLocalizedString("Learn More", comment: "Learn More")
        }
    }
}
