// Copyright © Blockchain Luxembourg S.A. All rights reserved.

// swiftlint:disable all

import Foundation

extension LocalizationConstants {

    public enum AnnouncementCards {

        // MARK: - Persistent

        public enum Welcome {
            public static let title = NSLocalizedString(
                "Welcome to Blockchain.com!",
                comment: "Welcome announcement card title"
            )
            public static let description = NSLocalizedString(
                "Here are a few tips to get your account up and running, we’ll also help you make sure everything is secure.",
                comment: "Welcome announcement card description"
            )
            public static let ctaButton = NSLocalizedString(
                "Tell Me More",
                comment: "Welcome announcement card CTA button title"
            )
            public static let skipButton = NSLocalizedString(
                "Maybe Later",
                comment: "Welcome announcement card skip button title"
            )
        }

        public enum VerifyEmail {
            public static let title = NSLocalizedString(
                "Verify Your Email Address",
                comment: "Verify email announcement card title"
            )
            public static let description = NSLocalizedString(
                "You need to confirm your email address so that we can keep you informed about your wallet.",
                comment: "Verify email announcement card description"
            )
            public static let ctaButton = NSLocalizedString(
                "Verify Email Address",
                comment: "Verify email announcement card CTA button title"
            )
        }

        public enum BackupFunds {
            public static let title = NSLocalizedString(
                "Wallet Recovery Phrase",
                comment: "Backup funds announcement card title"
            )
            public static let description = NSLocalizedString(
                "You control your crypto. Write down your recovery phrase to restore all your funds in case you lose your password.",
                comment: "Backup funds announcement card description"
            )
            public static let ctaButton = NSLocalizedString(
                "Backup Phrase",
                comment: "Backup funds announcement card CTA button title"
            )
        }

        public enum SimpleBuyPendingTransaction {
            public static let titlePrefix = NSLocalizedString(
                "Pending",
                comment: "Simple Buy Pending Transaction announcement card title"
            )
            public static let titleSuffix = NSLocalizedString(
                "Buy",
                comment: "Simple Buy Pending Transaction announcement card title"
            )
            public static let descriptionPrefix = NSLocalizedString(
                "Once we receive your bank transfer, your",
                comment: "Simple Buy Pending Transaction announcement card description prefix"
            )
            public static let descriptionSuffix = NSLocalizedString(
                "buy order will complete",
                comment: "Simple Buy Pending Transaction announcement card description suffix"
            )
            public static var ctaButton: String {
                SimpleBuy.Checkout.Button.transferDetails
            }
        }

        public enum SimpleBuyFinishSignup {
            public static let title = NSLocalizedString(
                "Finish Signing Up. Buy Crypto.",
                comment: "Simple Buy KYC Incomplete announcement card title"
            )
            public static let description = NSLocalizedString(
                "You’re almost done signing up for your Blockchain.com Wallet. Once you finish and get approved, start buying crypto.",
                comment: "Simple Buy KYC Incomplete announcement card description"
            )
            public static let ctaButton = NSLocalizedString(
                "Continue",
                comment: "Simple Buy KYC Incomplete announcement card CTA button title"
            )
        }

        // MARK: - One time

        public enum ViewNFT {
            public static let title = NSLocalizedString(
                "View NFTs In Your Wallet",
                comment: "View NFTs In Your Wallet"
            )
            public static let description = NSLocalizedString(
                "Soon you will be able to view your NFTs right from the comfort of your wallet.",
                comment: "Soon you will be able to view your NFTs right from the comfort of your wallet."
            )
            public static let buttonTitle = NSLocalizedString(
                "Join Waitlist",
                comment: "Join Waitlist"
            )
        }

        public enum IdentityVerification {
            public static let title = NSLocalizedString(
                "Finish Verifying Your Account",
                comment: "Finish identity verification announcement card title"
            )
            public static let description = NSLocalizedString(
                "Pick up where you left off and complete your identity verification.",
                comment: "Finish identity verification announcement card description"
            )
            public static let ctaButton = NSLocalizedString(
                "Continue Verification",
                comment: "Finish identity verification announcement card CTA button title"
            )
        }

        public enum NewAsset {
            public static let title = NSLocalizedString(
                "%@ (%@) is Now Trading",
                comment: "New asset announcement card title."
            )
            public static let description = NSLocalizedString(
                "Buy, sell, swap, send, receive and store %@ in your Blockchain.com Wallet.",
                comment: "New asset announcement card description."
            )
            public static let ctaButton = NSLocalizedString(
                "Buy %@",
                comment: "New asset card CTA button title."
            )
        }

        public enum AssetRename {
            public static let title = NSLocalizedString(
                "%@ has a new name",
                comment: "Asset Rename announcement card title."
            )
            public static let description = NSLocalizedString(
                "Heads up: %@ has renamed to %@. All balances are unaffected.",
                comment: "Asset Rename announcement card description."
            )
            public static let ctaButton = NSLocalizedString(
                "Trade %@",
                comment: "Asset Rename card CTA button title."
            )
        }

        public enum UKEntitySwap {

            public static let title = NSLocalizedString(
                "New legal entity",
                comment: "UKEntitySwap announcement card title."
            )

            public static let description = NSLocalizedString(
                "Starting later this month, UK customers will be served by our European subsidiary, Blockchain (LT), UAB. You will not experience any changes in user experience or lose access to your funds during this transition.",
                comment: "UKEntitySwap announcement card description."
            )

            public static let ctaButtonPrimary = NSLocalizedString(
                "I Understand",
                comment: "UKEntitySwap card CTA button title."
            )

            public static let ctaButtonSecondary = NSLocalizedString(
                "Learn More",
                comment: "UKEntitySwap card CTA button title."
            )
        }

        public enum CloudBackup {
            public static let title = NSLocalizedString(
                "Introducing Cloud Backups",
                comment: "Cloud Backup announcement card title"
            )
            public static let description = NSLocalizedString(
                "You can now backup your wallet securely to the cloud. You can opt-out of backups in your wallet settings.",
                comment: "Cloud Backup announcement card description"
            )
            public static let ctaButton = NSLocalizedString(
                "Learn more",
                comment: "Cloud Backup announcement card CTA button title"
            )
        }

        public enum MajorProductBlocked {
            public static let title = NSLocalizedString(
                "Trading Restricted",
                comment: "EU_5_SANCTION card title."
            )

            public static let ctaButtonLearnMore = NSLocalizedString(
                "Learn More",
                comment: "EU_5_SANCTION card CTA button title."
            )

            public static let defaultMessage = NSLocalizedString(
                "Default message for inelibility",
                comment: "This operation cannot be performed at this time. Please try again later."
            )
        }

        public enum Exchange {
            public static let title = NSLocalizedString(
                "Introducing the Exchange",
                comment: "Exchange announcement card title"
            )
            public static let description = NSLocalizedString(
                "It's time to Level Up to a better crypto exchange. Buy, sell, and trade more digital assets in the Blockchain.com Exchange.",
                comment: "Exchange announcement card description"
            )
            public static let ctaButton = NSLocalizedString(
                "Checkout the Exchange",
                comment: "Exchange announcement card CTA button title"
            )
        }

        public enum CashIdentityVerification {
            public static let title = NSLocalizedString("Keep Cash in Your Wallet", comment: "Keep Cash in Your Wallet")
            public static let description = NSLocalizedString(
                "Verify your identity to deposit cash into the Wallet and buy crypto.",
                comment: "Verify your identity to deposit cash into the Wallet and buy crypto."
            )
            public static let badgeName = NSLocalizedString("NEW", comment: "NEW")
            public static let learnMore = NSLocalizedString("Learn More", comment: "Learn More")
        }

        public enum InterestIdentityVerification {
            public static let title = NSLocalizedString("Earn 9.0% Rewards", comment: "Earn 4.5% Rewards")
            public enum Description {
                public static let kycd = NSLocalizedString(
                    "Start earning up to 9.0% rewards on your crypto.",
                    comment: "Start earning up to 9.0% rewards on your crypto."
                )
                public static let notKYCd = NSLocalizedString(
                    "Verify your identity and start earning up to 9.0% rewards on your crypto.",
                    comment: "Verify your identity and start earning up to 9.0% rewards on your crypto."
                )
            }

            public static let learnMore = NSLocalizedString("Learn More", comment: "Learn More")
        }

        public enum FiatFundsLinkBank {
            public static let title = NSLocalizedString("Link a Bank to Buy Crypto", comment: "Link a Bank to Buy Crypto")
            public static let description = NSLocalizedString(
                "Hold cash in your Blockchain.com Wallet. Deposit and Withdraw at anytime.",
                comment: "Hold cash in your Blockchain.com Wallet. Deposit and Withdraw at anytime."
            )
            public static let linkABank = NSLocalizedString("Link a Bank", comment: "Link a Bank")
        }

        public enum Bitpay {
            public static let description = NSLocalizedString(
                "With BitPay, you can now use your Blockchain wallet for purchases with supporting retailers.",
                comment: "Bitpay announcement card description"
            )
        }

        public enum WalletConnect {
            public static let title = NSLocalizedString(
                "WalletConnect is Now Available!",
                comment: "WalletConnect announcement card title"
            )
            public static let description = NSLocalizedString(
                "Securely connect your wallet to any web 3.0 application. ",
                comment: "WalletConnect announcement card description"
            )
            public static let ctaButton = NSLocalizedString(
                "Learn more",
                comment: "WalletConnect announcement card CTA button title"
            )
        }

        public enum ApplePay {
            public static let title = NSLocalizedString(
                "New: Apple Pay",
                comment: "Apple Pay announcement card title"
            )
            public static let description = NSLocalizedString(
                "Enjoy frictionless crypto purchases with Apple Pay.",
                comment: "Apple Pay announcement card description"
            )
            public static let ctaButton = NSLocalizedString(
                "Buy Crypto",
                comment: "Apple Pay announcement card CTA button title"
            )
        }

        public enum TaxCenter {
            public static let title = NSLocalizedString(
                "Tax Center is Now Available!",
                comment: "Tax Center announcement card title"
            )
            public static let description = NSLocalizedString(
                "In partnership with CoinTracker, our new Tax Center is now live. Connect to your account on web and go to Account -> Tax Center.",
                comment: "Tax Center announcement card description"
            )
            public static let ctaButton = NSLocalizedString(
                "OK",
                comment: "Tax Center announcement card CTA button title"
            )
        }

        // MARK: - Periodic

        public enum BuyBitcoin {
            public static let title = NSLocalizedString(
                "Buy Crypto",
                comment: "Buy BTC announcement card title"
            )
            public static let description = NSLocalizedString(
                "We can help you buy in just a few simple steps.",
                comment: "Buy BTC announcement card description"
            )
            public static let ctaButton = NSLocalizedString(
                "Buy Crypto Now",
                comment: "Buy BTC announcement card CTA button title"
            )
        }

        public enum NewSwap {
            public enum Promo {
                public static let title = NSLocalizedString(
                    "Swap Faster. Cheaper. Better.",
                    comment: ""
                )
                public static let description = NSLocalizedString(
                    "Get Full Access and Swap faster, with higher limits, lower fees, and a better experience.",
                    comment: ""
                )
                public static let ctaButton = NSLocalizedString(
                    "Upgrade now",
                    comment: ""
                )
            }

            public enum Eligible {
                public static let title = NSLocalizedString(
                    "Swap it like it’s hot.",
                    comment: ""
                )
                public static let description = NSLocalizedString(
                    "Faster. Cheaper. Better. Our new Swap experience lets you exchange crypto in fewer taps.",
                    comment: ""
                )
                public static let ctaButton = NSLocalizedString(
                    "Swap Now",
                    comment: ""
                )
            }

            public enum NotEligible {
                public static let title = NSLocalizedString(
                    "Swap better.",
                    comment: ""
                )
                public static let description = NSLocalizedString(
                    "We’ve updated Swap with a new look and better experience.",
                    comment: ""
                )
                public static let ctaButton = NSLocalizedString(
                    "Swap Now",
                    comment: ""
                )
            }
        }

        public enum Swap {
            public static let title = NSLocalizedString(
                "Trade Crypto",
                comment: "Swap announcement card title"
            )
            public static let description = NSLocalizedString(
                "Trade one crypto for another without giving up control of your keys. Get competitive, real-time prices and fast on-chain settlement.",
                comment: "Swap announcement card description"
            )
            public static let ctaButton = NSLocalizedString(
                "Check out Swap",
                comment: "Swap announcement card CTA button title"
            )
        }

        public enum TransferInCrypto {
            public static let title = NSLocalizedString(
                "Transfer In Crypto",
                comment: "Transfer crypto announcement card title"
            )
            public static let description = NSLocalizedString(
                "Deposit crypto in your wallet to get started. It's the best way to store your crypto while keeping control of your keys.",
                comment: "Transfer crypto announcement card description"
            )
            public static let ctaButton = NSLocalizedString(
                "Get Started",
                comment: "Transfer crypto announcement card CTA button title"
            )
        }

        public enum ResubmitDocuments {
            public static let title = NSLocalizedString(
                "Documents Needed",
                comment: "The title of the action on the announcement card for when a user needs to submit documents to verify their identity."
            )
            public static let description = NSLocalizedString(
                "We had some issues with the documents you’ve supplied. Please try uploading the documents again to continue with your verification.",
                comment: "The description on the announcement card for when a user needs to submit documents to verify their identity."
            )
            public static let ctaButton = NSLocalizedString(
                "Upload Documents",
                comment: "The title of the action on the announcement card for when a user needs to submit documents to verify their identity."
            )
        }

        public enum ResubmitDocumentsAfterRecovery {
            public static let title = NSLocalizedString(
                "Documents Needed",
                comment: "The title of the action on the announcement card for when a user needs to submit documents to re-verify their identity."
            )
            public static let description = NSLocalizedString(
                "Please re-verify your identity to complete account recovery. Some features may not be available until you do.",
                comment: "The description on the announcement card for when a user needs to submit documents to re-verify their identity."
            )
            public static let ctaButton = NSLocalizedString(
                "Re-verify Now",
                comment: "The title of the action on the announcement card for when a user needs to submit documents to re-verify their identity."
            )
        }

        public enum TwoFA {
            public static let title = NSLocalizedString(
                "Enable 2-Step Verification",
                comment: "2FA announcement card title"
            )
            public static let description = NSLocalizedString(
                "Protect your wallet from unauthorized access by enabling 2-Step Verification.",
                comment: "2FA announcement card description"
            )
            public static let ctaButton = NSLocalizedString(
                "Enable 2-Step Verification",
                comment: "2FA announcement card CTA button title"
            )
        }

        public enum ClaimFreeDomain {
            public static let title = NSLocalizedString(
                "Claim Your Free Domain!",
                comment: "Claim free domain annoucement card title"
            )
            public static let description = NSLocalizedString(
                "Get a free .blockchain domain through Unstoppable Domains. Use your domain to receive crypto and much more.",
                comment: "Claim free domain annoucement card description"
            )
            public static let button = NSLocalizedString(
                "Claim Domain",
                comment: "Claim free domain annoucement card button"
            )
        }
    }
}
