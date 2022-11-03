// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Localization

extension LocalizationConstants {
    enum Checkout {
        static let swapTitle = NSLocalizedString(
            "Confirm Swap",
            comment: "Swap confirmation navigation bar title"
        )
        static let buyTitle = NSLocalizedString(
            "Confirm",
            comment: "Buy confirmation navigation bar title"
        )
        static let applePay = NSLocalizedString(
            "Apple Pay",
            comment: "Payment Method: Apple Pay"
        )
        static let funds = NSLocalizedString(
            "Funds",
            comment: "Payment Method: Funds"
        )
        static let bank = NSLocalizedString(
            "Bank",
            comment: "Payment Method: Bank"
        )
    }
}

extension LocalizationConstants.Checkout {
    enum DepositTermsAvailableDisplayMode {
        static let immediately = NSLocalizedString(
            "Immediately",
            comment: "Immediately Available To Withdraw or Trade Display Mode"
        )
        static let maxMinute = NSLocalizedString(
            "In %@",
            comment: "Max Minute Available To Withdraw or Trade Display Mode"
        )
        static let minuteRange = NSLocalizedString(
            "Between %@ and %@ minutes",
            comment: "Minute Range Available To Withdraw or Trade Display Mode"
        )
        static let dayRange = NSLocalizedString(
            "Between %@ and %@",
            comment: "Day Range Available To Withdraw or Trade Display Mode"
        )
    }
}
