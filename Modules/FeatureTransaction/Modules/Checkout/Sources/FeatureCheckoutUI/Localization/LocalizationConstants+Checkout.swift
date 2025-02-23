// Copyright © Blockchain Luxembourg S.A. All rights reserved.
// swiftlint:disable line_length

import Localization

extension LocalizationConstants {
    enum Checkout {
        enum Label {
            static let checkout = NSLocalizedString(
                "Checkout",
                comment: "Checkout title"
            )
            static let fetchingQuote = NSLocalizedString(
                "Fetching Quote",
                comment: "Checkout Fetching Quote"
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
                "Blockchain.com requires a fee for this payment method",
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
            static let soon = NSLocalizedString(
                "soon",
                comment: "Quote time soon."
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

extension LocalizationConstants.Checkout {
    enum AvailableToTradeInfo {
        static let title = NSLocalizedString(
            "Available to withdraw or send",
            comment: "Available To Trade Info title"
        )

        static let description = NSLocalizedString(
            "Withdrawal holds protect you from fraud and theft if your Blockchain.com account is compromised. The hold period starts once funds are received in your account.",
            comment: "Available To Trade Info description"
        )

        static let learnMoreButton = NSLocalizedString(
            "Learn More",
            comment: "Available To Trade Info learn more button"
        )
    }

    enum ACHTermsInfo {
        static let title = NSLocalizedString(
            "Terms & Conditions",
            comment: "ACH Terms & Conditions title"
        )

        static let simpleBuyDescription = NSLocalizedString(
            "You authorize Blockchain.com, Inc. to debit your %@ account for up to %@ via Bank Transfer (ACH) and, if necessary, to initiate credit entries/adjustments for any debits made in error to your account at the financial institution where you hold your account. You acknowledge that the origination of ACH transactions to your account complies with the provisions of U.S. law. You agree that this authorization cannot be revoked.\n\nYour deposit will be credited to your Blockchain.com account within 0-4 business days at the rate shown at the time of your purchase. You can withdraw these funds from your Blockchain.com account %@ after Blockchain.com receives funds from your financial institution.",
            comment: "ACH Terms & Conditions description"
        )

        static let recurringBuyDescription = NSLocalizedString(
            "You authorize Blockchain.com, Inc. to debit your %@ account for up to %@ (the recurring purchase amount) via Bank Transfer (ACH) and, if necessary, to initiate credit entries/adjustments for any debits made in error to your account at the above Financial Institution. You acknowledge that the origination of ACH transactions to your account comply with the provisions of U.S. law. You agree that this authorization cannot be revoked.\n\nYour deposit will be credited to your Blockchain.com account within 0-4 business days at the rate shown at the time of your purchase. You can withdraw these funds from your Blockchain.com account %@ after Blockchain.com receives funds from your Financial Institution.",
            comment: "ACH Terms & Conditions description"
        )

        static let doneButton = NSLocalizedString(
            "OK",
            comment: "ACH Terms & Conditions done button"
        )
    }

    enum AchTransferDisclaimer {
        static let simpleBuyDescription = NSLocalizedString(
            "By placing this order, you authorize Blockchain.com, Inc. to debit %@ from your bank account for a %@ purchase at a quoted price of %@.",
            comment: "Terms & Conditions description"
        )

        static let recurringBuyDescription = NSLocalizedString(
            "By placing this order, you authorize Blockchain.com, Inc. to debit your %@ account for up to %@ (the recurring purchase amount) via Bank Transfer (ACH).",
            comment: "Terms & Conditions description"
        )

        static let readMoreButton = NSLocalizedString(
            "Read More",
            comment: "Terms & Conditions done button"
        )
    }
}
