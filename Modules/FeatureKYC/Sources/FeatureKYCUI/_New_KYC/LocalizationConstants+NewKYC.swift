// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation
import Localization

// swiftlint:disable line_length
extension LocalizationConstants {

    enum NewKYC {

        // MARK: - Generic Error

        enum GenericError {
            static let title = NSLocalizedString(
                "Something went wrong",
                comment: "A generic alert's title"
            )

            static let retryButtonTitle = NSLocalizedString(
                "Try again",
                comment: "A generic alert's retry button"
            )

            static let cancelButtonTitle = NSLocalizedString(
                "Cancel",
                comment: "A generic alert's cancel button"
            )
        }

        // MARK: - Email Verification Master View

        enum EmailVerification {
            static let couldNotLoadVerificationStatusAlertMessage = NSLocalizedString(
                "We couldn't load your email's verification status. Please try again.",
                comment: "An alert's message to be presented when the app is unable to check the email verification status of a user"
            )
        }

        // MARK: - Edit Email View

        enum EditEmail {
            static let title = NSLocalizedString(
                "Edit Email Address",
                comment: "The title for the view where a user can update their email address in the email verification flow"
            )
            static let message = NSLocalizedString(
                "Enter your email address below and click Save. We’ll send you a verification email straighaway.",
                comment: "The message shown under the tile for the view where a user can update their email address in the email verification flow"
            )

            static let saveButtonTitle = NSLocalizedString(
                "Save",
                comment: "The title for the 'Save' button in the Edit Email view in the Email Verification Flow"
            )

            static let editEmailFieldLabel = NSLocalizedString(
                "Your Email",
                comment: "The label on top of the text field within the Edit Email view in the Email Verification Flow"
            )
            static let invalidEmailInputMessage = NSLocalizedString(
                "Invalid email address",
                comment: "A message shown when the user types an invalid email within the Edit Email View in the Email Verification Flow"
            )

            static let couldNotUpdateEmailAlertMessage = NSLocalizedString(
                "We couldn't update your email address. Please check your Internet connection and try again.",
                comment: "An alert's message shown when we can't update a user's email address on our server from the Email Verification Flow"
            )
        }

        // MARK: - Email Verification Help View

        enum EmailVerificationHelp {
            static let title = NSLocalizedString(
                "Didn’t get the email?",
                comment: "The title for the Help view within the Email Verification Flow"
            )
            static let message = NSLocalizedString(
                "We can send the email again or let’s update your email address.",
                comment: "The message under the title for the Help view within the Email Verification Flow"
            )

            static let sendEmailAgainButtonTitle = NSLocalizedString(
                "Send Again",
                comment: "The 'resend verification email' button within the Help section of the Email Verification Flow"
            )
            static let editEmailAddressButtonTitle = NSLocalizedString(
                "Edit Email Address",
                comment: "The 'edit email address' button within the Help section of the Email Verification Flow"
            )

            static let couldNotSendEmailAlertMessage = NSLocalizedString(
                "We couldn't send a verification email at this time. Please check your Internet connection and try again.",
                comment: "An alert's message to show when we can't re-send a verification email to the user"
            )
        }

        // MARK: - Email Verified View

        enum EmailVerified {
            static let title = NSLocalizedString(
                "Email Verified",
                comment: "The title for the view confirming a user's email got correctly verified within the Email Verification Flow"
            )
            static let message = NSLocalizedString(
                "Success! You're email has been confirmed.",
                comment: "The message under the title for the view confirming a user's email got correctly verified within the Email Verification Flow"
            )

            static let continueButtonTitle = NSLocalizedString(
                "Next",
                comment: "The 'continue' button for the view confirming a user's email got correctly verified within the Email Verification Flow"
            )
        }

        // MARK: - Verify Email View

        enum VerifyEmail {
            static let title = NSLocalizedString(
                "Verify Your Email",
                comment: "The title for the view asking the user to confirm their email address within the Email Verification Flow"
            )

            static func message(with emailAddress: String) -> String {
                let format = NSLocalizedString(
                    "We sent a verification email to %@. Please click the link in the email to continue.",
                    comment: "The message under the title for the view asking the user to confirm their email address within the Email Verification Flow"
                )
                return String(format: format, emailAddress)
            }

            static let checkInboxButtonTitle = NSLocalizedString(
                "Check My Inbox",
                comment: "The 'check your inbox' button in the view asking the user to confirm their email address within the Email Verification Flow"
            )
            static let getHelpButtonTitle = NSLocalizedString(
                "Didn't get the email?",
                comment: "The 'help' button in the view asking the user to confirm their email address within the Email Verification Flow"
            )
        }

        // MARK: - Unlock Trading View (Prompt to upgrade to Tier 2)

        enum UnlockTrading {
            static let title = NSLocalizedString(
                "Upgrade Your Profile.\nBuy, Sell & Swap More Crypto",
                comment: "KYC Upgrade Prompt - Title"
            )

            static let message = NSLocalizedString(
                "Verify to unlock access to Buying, Selling, Swapping & Rewards Accounts.",
                comment: "KYC Upgrade Prompt - Message"
            )

            static let navigationTitle = NSLocalizedString(
                "Verify Now",
                comment: "KYC Upgrade Prompt - Navigation Bar Title"
            )

            static let cta_verified = NSLocalizedString(
                "Get Full Access",
                comment: "KYC Upgrade Prompt - Upgrade to Full Access CTA Title"
            )

            static let cta_basic = NSLocalizedString(
                "Get Limited Access",
                comment: "KYC Upgrade Prompt - Upgrade to Limited Access CTA Title"
            )

            static let basicTierName = NSLocalizedString(
                "Limited Access",
                comment: "KYC Upgrade Prompt - Tier 1 Name"
            )

            static let verifiedTierName = NSLocalizedString(
                "Full Access",
                comment: "KYC Upgrade Prompt - Tier 2 Name"
            )

            static let benefit_basicTier_title = NSLocalizedString(
                "Limited Access Level",
                comment: "KYC Upgrade Prompt - Limited Access Tier Benefit Title"
            )

            static let benefit_tier_active_badgeTitle = NSLocalizedString(
                "Active",
                comment: "KYC Upgrade Prompt - Active Tier Benefit Badge Title"
            )

            static let benefit_tier_nonActive_badgeTitle = NSLocalizedString(
                "Apply Now",
                comment: "KYC Upgrade Prompt - Non-Active Tier Benefit Badge Title"
            )

            static let benefit_basic_sendAndReceive_title = NSLocalizedString(
                "Send & Receive Crypto",
                comment: "KYC Upgrade Prompt - Send & Receive Benefit Title"
            )

            static let benefit_basic_sendAndReceive_info = NSLocalizedString(
                "Between Private Key Wallets",
                comment: "KYC Upgrade Prompt - Send & Receive Benefit Badge Detail"
            )

            static let benefit_basic_swap_title = NSLocalizedString(
                "Swap Crypto",
                comment: "KYC Upgrade Prompt - Swap Benefit Limited Access Title"
            )

            static let benefit_basic_swap_info = NSLocalizedString(
                "1-Time Between Private Key Wallets",
                comment: "KYC Upgrade Prompt - Swap Benefit Limited Access Badge Detail"
            )

            static let benefit_verifiedTier_title = NSLocalizedString(
                "Full Access Level",
                comment: "KYC Upgrade Prompt - Full Access Tier Benefit Title"
            )

            static let benefit_verified_swap_title = NSLocalizedString(
                "Swap Crypto",
                comment: "KYC Upgrade Prompt - Swap Full Access Benefit Title"
            )

            static let benefit_verified_swap_info = NSLocalizedString(
                "Between All Wallets & Accounts",
                comment: "KYC Upgrade Prompt - Swap Full Access Benefit Info"
            )

            static let benefit_verified_buyAndSell_title = NSLocalizedString(
                "Buying & Selling",
                comment: "KYC Upgrade Prompt - Buy & Sell Full Access Benefit Title"
            )

            static let benefit_verified_buyAndSell_info = NSLocalizedString(
                "Card or Banking Methods",
                comment: "KYC Upgrade Prompt - Buy & Sell Full Access Benefit Info"
            )

            static let benefit_verified_rewards_title = NSLocalizedString(
                "Earn Rewards",
                comment: "KYC Upgrade Prompt - Rewards Full Access Benefit Title"
            )

            static let benefit_verified_rewards_info = NSLocalizedString(
                "Earn Rewards On Your Crypto",
                comment: "KYC Upgrade Prompt - Rewards Full Access Benefit Info"
            )
        }

        enum UnlockTradingAlert {

            static let title = NSLocalizedString(
                "We are updating our account verification requirements",
                comment: "Title for alert shown to prompt Limited Access Tier users to upgrade"
            )

            static let message = NSLocalizedString(
                "To buy, sell, and swap, you will need to verify your identity.",
                comment: "Message for alert shown to prompt Limited Access Tier users to upgrade"
            )

            static let primaryCTA = NSLocalizedString(
                "Verify Now",
                comment: "Primary CTA for alert shown to prompt Limited Access Tier users to upgrade"
            )
        }

        // MARK: - KYC Steps

        enum Steps {

            enum AccountUsage {

                static let title = NSLocalizedString(
                    "Use of Account Information",
                    comment: "KYC Step - Account Usage Questions - Screen Title"
                )

                static let skipButtonTitle = NSLocalizedString(
                    "Skip",
                    comment: "KYC Step - Account Usage Questions - Skip Button Title"
                )

                static let submitActionTitle = NSLocalizedString(
                    "Next",
                    comment: "KYC Step - Account Usage Questions - Submit Action Title"
                )

                static let stepNotNeededTitle = NSLocalizedString(
                    "You're all set",
                    comment: "KYC Step - Account Usage Questions - Step skipped title"
                )

                static let stepNotNeededMessage = NSLocalizedString(
                    "Please continue to the next step by tapping the button below.",
                    comment: "KYC Step - Account Usage Questions - Step skipped message"
                )

                static let stepNotNeededContinueCTA = NSLocalizedString(
                    "Continue",
                    comment: "KYC Step - Account Usage Questions - Step skipped continue CTA"
                )
            }
        }
    }
}
