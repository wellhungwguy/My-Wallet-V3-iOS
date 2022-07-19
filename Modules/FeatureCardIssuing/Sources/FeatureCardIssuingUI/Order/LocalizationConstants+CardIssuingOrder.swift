// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Localization

extension LocalizationConstants.CardIssuing {

    enum Order {
        enum Intro {
            static let title = NSLocalizedString(
                "Get the Blockchain.com\nVisa Card",
                comment: "Card Issuing: Order screen title"
            )

            static let caption = NSLocalizedString(
                "Spend your crypto or cash without fees.\nEarn 1% back in crypto.",
                comment: "Card Issuing: Order screen caption"
            )

            enum Button {
                enum Title {
                    static let order = NSLocalizedString(
                        "Order My Card",
                        comment: "Card Issuing: Order button"
                    )

                    static let link = NSLocalizedString(
                        "Already Have A Card? Link It Here",
                        comment: "Card Issuing: Link a card button"
                    )
                }
            }
        }

        enum Selection {
            enum Navigation {
                static let title = NSLocalizedString(
                    "Select Your Card",
                    comment: "Card Issuing: Select your card navigation title"
                )
            }

            static let acceptTerms = NSLocalizedString(
                "I agree to Blockchain.com's Terms of Service",
                comment: "Card Issuing: Accept Terms & Conditions"
            )

            enum Button {
                enum Title {
                    static let details = NSLocalizedString(
                        "See Card Details ->",
                        comment: "Card Issuing: See card details button"
                    )

                    static let create = NSLocalizedString(
                        "Create Card",
                        comment: "Card Issuing: Create card button"
                    )
                }
            }
        }

        enum Details {

            enum Rewards {
                static let title = NSLocalizedString(
                    "Crypto Rewards",
                    comment: "Card Issuing: Cashback Rewards title"
                )

                static let description = NSLocalizedString(
                    "Earn 1% back in crypto rewards on all your purchases.",
                    comment: "Card Issuing: Cashback Rewards description"
                )
            }

            enum Fees {
                static let title = NSLocalizedString(
                    "No Fees",
                    comment: "Card Issuing: Fees item"
                )

                static let description = NSLocalizedString(
                    "No sign up fees. No annual fees. No transaction fees.",
                    comment: "Card Issuing: Fees description"
                )
            }

            enum Legal {
                static let navigationTitle = NSLocalizedString(
                    "Legal Disclosures",
                    comment: "Card Issuing: Legal Navigation Title"
                )

                static let title = NSLocalizedString(
                    "The Legal Stuff",
                    comment: "Card Issuing: Legal Title"
                )

                static let contactless = NSLocalizedString(
                    "Contactless Payment",
                    comment: "Card Issuing: Contactless Payment"
                )

                static let consumerFinancialProtectionBureau = NSLocalizedString(
                    "Consumer Financial Protection Bureau",
                    comment: "Card Issuing: Consumer Financial Protection Bureau"
                )

                static let shortFormDisclosure = NSLocalizedString(
                    "Short Form Disclosure",
                    comment: "Card Issuing: Short Form Disclosure"
                )

                static let blockchainTermsAndConditions = NSLocalizedString(
                    "Blockchain.com Terms & Conditions",
                    comment: "Card Issuing: Blockchain.com Terms & Conditions"
                )

                static let termsAndConditions = NSLocalizedString(
                    "Terms & Conditions",
                    comment: "Card Issuing: Terms & Conditions"
                )
            }
        }

        enum Processing {
            enum Success {
                static let title = NSLocalizedString(
                    "Card Successfully Created!",
                    comment: "Card Issuing: Card Successfully Created!"
                )

                static let caption = NSLocalizedString(
                    "Welcome to the club, to view your card dashboard please press Continue below.",
                    comment: "Card Issuing: Order success caption"
                )

                static let goToDashboard = NSLocalizedString(
                    "Go To Dashboard",
                    comment: "Card Issuing: Go To Dashboard"
                )
            }

            enum Processing {
                static let title = NSLocalizedString(
                    "Processing...",
                    comment: "Card Issuing: Card Creation Processing"
                )
            }
        }
    }
}

extension LocalizationConstants.CardIssuing.Order {

    enum KYC {

        enum Buttons {

            static let next = NSLocalizedString(
                "Next",
                comment: "Card Issuing: Next Button"
            )

            static let save = NSLocalizedString(
                "Save",
                comment: "Card Issuing: Save Button"
            )

            static let cancel = NSLocalizedString(
                "Cancel",
                comment: "Card Issuing: Cancel Button"
            )
        }

        enum Address {

            enum Navigation {

                static let title = NSLocalizedString(
                    "Residential Address",
                    comment: "Card Issuing: Residential Address Navigation Title"
                )
            }

            static let title = NSLocalizedString(
                "Verify Your Address",
                comment: "Card Issuing: Verify Your Address Title"
            )

            static let description = NSLocalizedString(
                """
                Confirm your residential address below to avoid delays. \
                Your will be able to specify a different shipping address later.
                """,
                comment: "Card Issuing: Verify Your Address Description"
            )

            enum Form {

                static let addressLine1 = NSLocalizedString(
                    "Address Line 1",
                    comment: "Card Issuing: Form Address Line 1"
                )

                static let addressLine2 = NSLocalizedString(
                    "Address Line 2",
                    comment: "Card Issuing: Form Address Line 1"
                )

                static let city = NSLocalizedString(
                    "City",
                    comment: "Card Issuing: Form City"
                )

                static let state = NSLocalizedString(
                    "State",
                    comment: "Card Issuing: Form State"
                )

                static let zip = NSLocalizedString(
                    "Zip",
                    comment: "Card Issuing: Form Zip"
                )

                static let country = NSLocalizedString(
                    "Country",
                    comment: "Card Issuing: Form Country"
                )

                enum Placeholder {

                    static let line = NSLocalizedString(
                        "1234 Road Street",
                        comment: "Card Issuing: Form Placeholder"
                    )

                    static let state = NSLocalizedString(
                        "FL",
                        comment: "Card Issuing: Form Placeholder"
                    )
                }
            }
        }

        enum SSN {

            enum Navigation {

                static let title = NSLocalizedString(
                    "SSN",
                    comment: "Card Issuing: SSN Navigation Title"
                )
            }

            static let title = NSLocalizedString(
                "Verify Your Identity",
                comment: "Card Issuing: Verify Your Identity Title"
            )

            static let description = NSLocalizedString(
                """
                Please confirm your SSN or Tax ID below to prevent others from \
                creating fraudulent accounts in your name.
                """,
                comment: "Card Issuing: Verify Your Identity Description"
            )

            enum Input {

                static let title = NSLocalizedString(
                    "SSN or Individual Tax ID #",
                    comment: "Card Issuing: SSN Input Title"
                )

                static let placeholder = NSLocalizedString(
                    "XX-XX-XXXX",
                    comment: "Card Issuing: SSN Input Placeholder"
                )

                static let caption = NSLocalizedString(
                    "Information secured with 256-bit encryption",
                    comment: "Card Issuing: SSN Input Encryption Caption"
                )
            }
        }
    }
}
