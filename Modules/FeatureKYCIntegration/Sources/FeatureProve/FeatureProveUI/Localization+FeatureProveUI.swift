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

extension LocalizationConstants {
    public enum EnterInformation {

        static let title = NSLocalizedString(
            "Verify your account",
            comment: "Enter Personal Information: Title"
        )

        static let loadingTitle = NSLocalizedString(
            "Verifying your information",
            comment: "Enter Personal Information: Verifying your information loading"
        )

        enum Body {

            static let title = NSLocalizedString(
                "Enter your information",
                comment: "Enter Personal Information: Body title"
            )

            static let subtitle = NSLocalizedString(
                "Please add your date of birth.",
                comment: "Enter Personal Information: Body subtitle"
            )
        }

        enum Buttons {

            static let continueTitle = NSLocalizedString(
                "Continue",
                comment: "Enter Personal Information: Continue Button"
            )
        }
    }
}

extension LocalizationConstants.EnterInformation.Body {
    public enum Form {

        static let dateOfBirthInputTitle = NSLocalizedString(
            "Date of birth",
            comment: "Enter Personal Information: Date Of Birth Input Title"
        )

        static let dateOfBirthInputHint = NSLocalizedString(
            "You must be 18 years or older.",
            comment: "Enter Personal Information: Date Of Birth Input Hint"
        )
    }
}

extension LocalizationConstants {
    public enum ConfirmInformation {

        static let title = NSLocalizedString(
            "Verify your account",
            comment: "Confirm Personal Information: Title"
        )

        static let loadingTitle = NSLocalizedString(
            "Verifying your account",
            comment: "Confirm Personal Information: Verifying your account loading"
        )

        enum Body {

            static let title = NSLocalizedString(
                "Confirm your information",
                comment: "Confirm Personal Information: Body title"
            )
        }

        enum Buttons {

            static let continueTitle = NSLocalizedString(
                "Continue",
                comment: "Confirm Personal Information: Continue Button"
            )
        }
    }
}

extension LocalizationConstants.ConfirmInformation.Body {
    public enum Form {

        static let firstNameInputTitle = NSLocalizedString(
            "First name",
            comment: "Confirm Personal Information: First Name Input Title"
        )

        static let lastNameInputTitle = NSLocalizedString(
            "Last name",
            comment: "Confirm Personal Information: Last Name Input Title"
        )

        static let addressNameInputTitle = NSLocalizedString(
            "Address",
            comment: "Confirm Personal Information: Address Input Title"
        )

        static let dateOfBirthInputTitle = NSLocalizedString(
            "Date of birth",
            comment: "Confirm Personal Information: Date Of Birth Input Title"
        )

        static let dateOfBirthInputHint = NSLocalizedString(
            "You must be 18 years or older.",
            comment: "Confirm Personal Information: Date Of Birth Input Hint"
        )

        static let phoneInputTitle = NSLocalizedString(
            "Phone number",
            comment: "Confirm Personal Information: Phone Input Title"
        )

        static let phoneInputHint = NSLocalizedString(
            "This information cannot be modified",
            comment: "Confirm Personal Information: Phone Input Hint"
        )
    }
}

extension LocalizationConstants {
    public enum SuccessfullyVerified {

        static let title = NSLocalizedString(
            "Verify your account",
            comment: "Successfully Verified: Title"
        )

        enum Body {

            static let title = NSLocalizedString(
                "Successfully verified",
                comment: "Successfully Verified: Body title"
            )

            static let subtitle = NSLocalizedString(
                "Congratulations! We successfully verified your identity. You can now buy, sell and swap cryptocurrencies at Blockchain.com",
                comment: "Successfully Verified: Body subtitle"
            )
        }

        enum Buttons {

            static let finishTitle = NSLocalizedString(
                "Get Started",
                comment: "Successfully Verified: Get started Button"
            )
        }
    }
}
