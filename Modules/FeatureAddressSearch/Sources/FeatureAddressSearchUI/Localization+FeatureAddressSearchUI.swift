// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import FeatureAddressSearchDomain
import Foundation
import Localization

extension LocalizationConstants {
    public enum AddressSearch {

        static let title = NSLocalizedString(
            "Home Address",
            comment: "Address Search: Home Address Title"
        )

        enum Buttons {

            static let next = NSLocalizedString(
                "Next",
                comment: "Address Search: Next Button"
            )

            static let save = NSLocalizedString(
                "Save",
                comment: "Address Search: Save Button"
            )

            static let cancel = NSLocalizedString(
                "Cancel",
                comment: "Address Search: Cancel Button"
            )

            static let edit = NSLocalizedString(
                "Edit",
                comment: "Address Search: Edit Button"
            )
        }
    }
}

extension LocalizationConstants.AddressSearch {

    enum SearchAddress {

        enum SearchBar {

            enum Placeholder {

                static let text = NSLocalizedString(
                    "Home Address",
                    comment: "Address Search: Search Address Placeholder"
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
                comment: "Address Search: Search Address Address not found"
            )

            enum Buttons {

                static let inputAddressManually = NSLocalizedString(
                    "My address is not here",
                    comment: "Address Search: Input Address Manually"
                )
            }
        }
    }
}

extension LocalizationConstants.AddressSearch {

    enum Form {

        static let addressLine1 = NSLocalizedString(
            "Home Address",
            comment: "Address Search: Form Address Line 1"
        )

        static let addressLine2 = NSLocalizedString(
            "Apt, Suite, Etc",
            comment: "Address Search: Form Address Line 2"
        )

        static let city = NSLocalizedString(
            "City",
            comment: "Address Search: Form City"
        )

        static let state = NSLocalizedString(
            "State",
            comment: "Address Search: Form State"
        )

        static let zip = NSLocalizedString(
            "Zip",
            comment: "Address Search: Form Zip"
        )

        static let country = NSLocalizedString(
            "Country",
            comment: "Address Search: Form Country"
        )

        enum Placeholder {

            static let line1 = NSLocalizedString(
                "1234 Road Street",
                comment: "Address Search: Form Placeholder"
            )

            static let line2 = NSLocalizedString(
                "Additional Information",
                comment: "Address Search: Form Placeholder"
            )
        }
    }
}
