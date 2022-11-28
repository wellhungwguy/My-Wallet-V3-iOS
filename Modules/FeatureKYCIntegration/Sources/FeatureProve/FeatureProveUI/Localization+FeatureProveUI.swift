// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation
import Localization

extension LocalizationConstants {
    public enum BeginVerification {

        static let title = NSLocalizedString(
            "Verify your account",
            comment: "Begin Verification: Title"
        )

        enum Body {

            static let title = NSLocalizedString(
                "Let’s gather your information",
                comment: "Begin Verification: Body title"
            )

            static let subtitle = NSLocalizedString(
                "Tap continue to begin the process.",
                comment: "Begin Verification: Body subtitle"
            )
        }

        enum Footer {

            static let title = NSLocalizedString(
                "By selecting “Continue”, you agree to the",
                comment: "Begin Verification: Footer title without terms part"
            )

            static let titleTerms = NSLocalizedString(
                "Blockchain.com Privacy Policy",
                comment: "Begin Verification: Footer terms part"
            )
        }

        enum Buttons {

            static let continueTitle = NSLocalizedString(
                "Continue",
                comment: "Begin Verification: Continue Button"
            )
        }
    }
}
