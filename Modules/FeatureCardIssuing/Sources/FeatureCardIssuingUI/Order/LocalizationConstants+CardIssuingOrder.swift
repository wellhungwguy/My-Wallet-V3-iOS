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

            static let fullDisclaimer = NSLocalizedString(
                """
                This Blockchain.com Visa® Card is issued by Pathward, \
                N.A., Member FDIC, pursuant to a license from Visa U.S.A. Inc. \
                Blockchain.com Visa card can be used everywhere Visa debit cards are accepted. \
                1No Blockchain.com Fees but a spread applies when we sell cryptocurrencies. \
                2This optional offer is not a Pathward product or service nor does Pathward endorse this offer.
                """,
                comment: "Card Issuing: Bottom Page Full Disclaimer"
            )
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

                    static let `continue` = NSLocalizedString(
                        "Continue",
                        comment: "Card Issuing: Continue button"
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

            static let edit = NSLocalizedString(
                "Edit",
                comment: "Card Issuing: Edit Button"
            )
        }

        enum Address {

            enum Navigation {

                static let title = NSLocalizedString(
                    "Address Verification",
                    comment: "Card Issuing: Address Verification Navigation Title"
                )
            }

            static let title = NSLocalizedString(
                "Home Address",
                comment: "Card Issuing: Home Address Title"
            )

            static let description = NSLocalizedString(
                """
                Confirm your address below. You will be able to specify a different shipping address later.
                """,
                comment: "Card Issuing: Verify Your Address Description"
            )

            static let commericalAddressNotAccepted = NSLocalizedString(
                "PO Box or commerical address will not be accepted",
                comment: "Card Issuing: Commerical address not accepted Title"
            )

            enum Form {

                static let addressLine1 = NSLocalizedString(
                    "Home Address",
                    comment: "Card Issuing: Form Address Line 1"
                )

                static let addressLine2 = NSLocalizedString(
                    "Apt, Suite, Etc",
                    comment: "Card Issuing: Form Address Line 2"
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

                    static let line1 = NSLocalizedString(
                        "1234 Road Street",
                        comment: "Card Issuing: Form Placeholder"
                    )

                    static let line2 = NSLocalizedString(
                        "Additional Information",
                        comment: "Card Issuing: Form Placeholder"
                    )
                }
            }
        }

        enum SearchAddress {

            enum SearchBar {

                enum Placeholder {

                    static let text = NSLocalizedString(
                        "Home Address",
                        comment: "Card Issuing: Search Address Placeholder"
                    )
                }

                static let invalidCharactersError = NSLocalizedString(
                    "Please make sure the search key has no special characters.",
                    comment: "Search address search bar no special characters error"
                )
            }

            enum AddressNotFound {

                static let title = NSLocalizedString(
                    "Address not found",
                    comment: "Card Issuing: Search Address Address not found"
                )

                enum Buttons {

                    static let inputAddressManually = NSLocalizedString(
                        "My address is not here",
                        comment: "Card Issuing: Input Address Manually"
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
