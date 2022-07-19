// Copyright © Blockchain Luxembourg S.A. All rights reserved.

// swiftlint:disable all

import Foundation

extension LocalizationConstants {
    public enum SimpleBuy {}
}

extension LocalizationConstants.SimpleBuy {

    public enum Withdrawal {
        public enum SummaryFailure {
            public enum Unknown {
                public static let title = NSLocalizedString("Oops!", comment: "Oops!")
                public static let description = NSLocalizedString(
                    "Something went wrong. Please go back and try again.",
                    comment: "Something went wrong. Please go back and try again."
                )
            }

            public enum WithdrawLocked {
                public static let title = NSLocalizedString("Funds Locked", comment: "Funds Locked")
                public static let description = NSLocalizedString(
                    "Your crypto will be available to be withdrawn within 3 days.",
                    comment: "Your crypto will be available to be withdrawn within 3 days."
                )
            }

            public static let action = NSLocalizedString("OK", comment: "OK")
        }
    }

    public enum AddPaymentMethodSelectionScreen {
        public static let title = NSLocalizedString(
            "Payment Methods",
            comment: "Simple Buy: Add Payment method selection screen title"
        )
        public enum LinkABank {
            public static let title = NSLocalizedString(
                "Easy Bank Transfer",
                comment: "Simple Buy: Add Payment method selection screen: link a bank title"
            )
            public static let descriptionLimit = NSLocalizedString(
                "Buy large amounts",
                comment: "Simple Buy: Add Payment method selection screen description"
            )
            public static let descriptionInfo = NSLocalizedString(
                "Link once and instantly buy crypto anytime.",
                comment: "Simple Buy: Add Payment method selection screen: description of bank account"
            )
        }

        public enum Card {
            public static let title = NSLocalizedString(
                "Credit or Debit Card",
                comment: "Simple Buy: Add Payment method selection screen: card title"
            )
            public static let descriptionLimit = NSLocalizedString(
                "Buy small amounts",
                comment: "Simple Buy: Add Payment method selection screen: description of card payment"
            )
            public static let descriptionInfo = NSLocalizedString(
                "Instantly buy crypto with any Visa or Mastercard.",
                comment: "Simple Buy: Add Payment method selection screen: description of card"
            )
            public static let badgeTitle = NSLocalizedString(
                "Most Popular",
                comment: "Simple Buy: Add Payment method selection screen: promotional text for card payment"
            )
        }

        public enum ApplePay {
            public static let title = NSLocalizedString(
                "Apple Pay",
                comment: "Simple Buy: Use Apple Pay as a payment method"
            )
            public static let descriptionLimit = NSLocalizedString(
                "Instantly Available",
                comment: "Simple Buy: Use Apple Pay: description"
            )
            public static let descriptionInfo = NSLocalizedString(
                "Simply tap to buy with Apple Pay",
                comment: "Simple Buy: Use Apple Pay: description of Apple Pay"
            )
        }

        public enum DepositCash {
            public static let usTitle = NSLocalizedString(
                "Wire Transfer",
                comment: "Simple Buy: Add Payment method selection screen: deposit funds title"
            )
            public static let europeTitle = NSLocalizedString(
                "Bank Transfer",
                comment: "Simple Buy: Add Payment method selection screen: deposit funds title"
            )
            public static let subtitle = NSLocalizedString(
                "Make a Deposit",
                comment: "Make a Deposit"
            )
            public static let description = NSLocalizedString(
                "If you'd prefer to deposit funds directly from your bank account first, follow the instructions on the next screen. Once your deposit arrives in your Blockchain.com account you can come back here to buy crypto.",
                comment: "If you'd prefer to deposit funds directly from your bank account first, follow the instructions on the next screen. Once your deposit arrives in your Blockchain.com account you can come back here to buy crypto."
            )
        }

        public enum Types {
            public static let bankWireTitle = NSLocalizedString(
                "Bank Wire Transfer",
                comment: "Simple Buy: Add Payment method selection screen: bank wire transfer"
            )
            public static let cardTitle = NSLocalizedString(
                "Credit or Debit Card",
                comment: "Simple Buy: Add Payment method selection screen: card"
            )
            public static let bankAccount = NSLocalizedString(
                "Bank Account",
                comment: "Simple Buy: Add Payment method selection screen: bank account"
            )
        }
    }

    public enum OrderState {
        public static let waitingOnFunds = NSLocalizedString(
            "Waiting on Funds",
            comment: "Simple Buy Order State: Waiting on Funds"
        )
        public static let pending = NSLocalizedString(
            "Pending",
            comment: "Simple Buy Order State: Pending"
        )
        public static let cancelled = NSLocalizedString(
            "Cancelled",
            comment: "Simple Buy Order State: Cancelled"
        )
        public static let expired = NSLocalizedString(
            "Expired",
            comment: "Simple Buy Order State: Expired"
        )
        public static let failed = NSLocalizedString(
            "Failed",
            comment: "Simple Buy Order State: Failed"
        )
        public static let completed = NSLocalizedString(
            "Completed",
            comment: "Simple Buy Order State: Finished"
        )
    }

    public enum TransferDetails {

        public static let error = NSLocalizedString(
            "Error, unable to load bank transfer details. We are working to resolve this.",
            comment: "Error, unable to load bank transfer details. We are working to resolve this issue."
        )

        public enum Funds {

            public enum Title {
                public static let addBankPrefix = NSLocalizedString(
                    "Add a",
                    comment: "Add"
                )
                public static let addBankSuffix = NSLocalizedString(
                    "Bank",
                    comment: "Bank"
                )
                public static let depositPrefix = NSLocalizedString(
                    "Deposit",
                    comment: "Deposit"
                )
            }

            public enum Notice {
                public enum Instructions {
                    public static let title = NSLocalizedString(
                        "Instructions",
                        comment: "Instructions"
                    )
                    public static let description = NSLocalizedString(
                        "To link your bank, send %@ or more to your %@ Account",
                        comment: "To link your bank, send [One dollar] or more to your [fiat currency code] Account"
                    )
                }

                public enum BankTransferOnly {
                    public static let title = NSLocalizedString(
                        "Bank Transfers Only",
                        comment: "Bank Transfers Only"
                    )
                    public static let description = NSLocalizedString(
                        "Only send funds from a bank account in your name. If not, your deposit could be delayed or rejected.",
                        comment: "Only send funds from a bank account in your name. If not, your deposit could be delayed or rejected."
                    )
                }

                public enum ProcessingTime {
                    public static let title = NSLocalizedString(
                        "Processing Time",
                        comment: "Processing Time"
                    )

                    public enum Description {
                        public static let USD = NSLocalizedString(
                            "Processing Time Funds will be credited to your USD wallet as soon as we receive them. Funds are generally available within one business day.",
                            comment: "Processing Time Funds will be credited to your USD wallet as soon as we receive them. Funds are generally available within one business day."
                        )
                        public static let EUR = NSLocalizedString(
                            "Funds will be credited to your EUR wallet as soon as we receive them. SEPA transfers usually take around 1 business day to reach us.",
                            comment: "Funds will be credited to your EUR wallet as soon as we receive them. SEPA transfers usually take around 1 business day to reach us."
                        )
                        public static let GBP = NSLocalizedString(
                            "Funds will be credited to your GBP wallet as soon as we receive them. In the UK Faster Payments Network, this can take a couple of hours.",
                            comment: "Funds will be credited to your GBP wallet as soon as we receive them. In the UK Faster Payments Network, this can take a couple of hours."
                        )
                        public static let ARS = NSLocalizedString(
                            "Funds will be credited to your ARS wallet as soon as we receive them. Funds are generally available within one business day.",
                            comment: "Funds will be credited to your ARS wallet as soon as we receive them. Funds are generally available within one business day."
                        )
                        public static let BRL = NSLocalizedString(
                            "Funds will be credited to your BRL wallet as soon as we receive them. Funds are generally available within one business day.",
                            comment: "Funds will be credited to your BRL wallet as soon as we receive them. Funds are generally available within one business day."
                        )
                    }
                }

                public static let recipientNameARS = NSLocalizedString(
                    "Important Transfer Information Only send funds from a bank account in your name. If not, your deposit could be delayed or rejected. Be sure to include your Reference ID.",
                    comment: "ARS Important Transfer Information Only send funds from a bank account in your name. If not, your deposit could be delayed or rejected. Be sure to include your Reference ID."
                )

                public static let recipientNameBRL = NSLocalizedString(
                    "Important Transfer Information Only send funds from a bank account in your name. If not, your deposit could be delayed or rejected. Be sure to include your Reference ID.",
                    comment: "BRL Important Transfer Information Only send funds from a bank account in your name. If not, your deposit could be delayed or rejected. Be sure to include your Reference ID."
                )

                public static let recipientNameUSD = NSLocalizedString(
                    "Important Transfer Information Only send funds from a bank account in your name. If not, your deposit could be delayed or rejected. Be sure to include your Reference ID.",
                    comment: "Important Transfer Information Only send funds from a bank account in your name. If not, your deposit could be delayed or rejected. Be sure to include your Reference ID."
                )

                public static let recipientNameEUR = NSLocalizedString(
                    "Your Recipient name above must match the account holder's name on your bank account for your transfer to be successful. Only send funds from a bank account in your name. If not, your deposit could be delayed or rejected.",
                    comment: "Your Recipient name above must match the account holder's name on your bank account for your transfer to be successful. Only send funds from a bank account in your name. If not, your deposit could be delayed or rejected."
                )
                public static let recipientNameGBPPrefix = NSLocalizedString(
                    "Only send funds from a bank account in your name. If not, your deposit could be delayed or rejected.\n By depositing funds to this account, you agree to",
                    comment: "Only send funds from a bank account in your name. If not, your deposit could be delayed or rejected.\n By depositing funds to this account, you agree to"
                )
                public static let termsAndConditions = NSLocalizedString(
                    "Terms & Conditions",
                    comment: "Terms & Conditions"
                )
                public static let recipientNameGBPSuffix = NSLocalizedString(
                    "of Modulr, our banking partner.",
                    comment: " , our banking partner."
                )
            }
        }

        public enum Button {
            public static let ok = NSLocalizedString(
                "OK",
                comment: "Simple Buy: Transfer Details Screen - ok button"
            )
        }
    }

    public enum Checkout {
        public enum Button {
            public static let transferDetails = NSLocalizedString(
                "View Bank Transfer Details",
                comment: "Simple Buy: Order Details - transfer details button"
            )
        }
    }

    public enum CashIntroductionScreen {
        public static let title = NSLocalizedString("Keep Cash in Your Wallet", comment: "Keep Cash in Your Wallet")
        public static let description = NSLocalizedString(
            "Verify your identity to deposit cash into your Wallet. Buy & Sell crypto. Withdraw at anytime.",
            comment: "Verify your identity to deposit cash into your Wallet. Buy & Sell crypto. Withdraw at anytime."
        )
        public static let notNow = NSLocalizedString("Not Now", comment: "Not Now")
        public static let verifyIdentity = NSLocalizedString("Verify Identity", comment: "Verify Identity")
        public enum List {
            public enum First {
                public static let title = NSLocalizedString("Verify Your Identity", comment: "Verify Your Identity")
                public static let description = NSLocalizedString(
                    "We need to make sure it's really you to prevent fraud by uploading an ID.",
                    comment: "We need to make sure it's really you to prevent fraud by uploading an ID."
                )
            }

            public enum Second {
                public static let title = NSLocalizedString("Deposit Cash", comment: "Deposit Cash")
                public static let description = NSLocalizedString(
                    "Transfer cash from your bank and enable your cash balances.",
                    comment: "Transfer cash from your bank and enable your cash balances."
                )
            }

            public enum Third {
                public static let title = NSLocalizedString("Buy Crypto with Cash", comment: "Buy Crypto with Cash")
                public static let description = NSLocalizedString(
                    "Use your cash wallet as a payment method to buy BTC, ETH, XLM & more.",
                    comment: "Use your cash wallet as a payment method to buy BTC, ETH, XLM & more."
                )
            }
        }
    }

    public enum LinkBankScreen {
        public static let title = NSLocalizedString(
            "Link a Bank",
            comment: "Link bank: top title label"
        )

        public static let subtitle = NSLocalizedString(
            "Blockchain.com uses %@ to verify your bank credentials & securely link your accounts.",
            comment: "Link bank: description label for bank linkage using a partner title"
        )

        public static let detailsTitle = NSLocalizedString(
            "Secure Connection",
            comment: "Link bank: detail title about secure connection"
        )

        public static let detailsSubtitle = NSLocalizedString(
            "%@ securely stores your credentials adhering to leading industry practices for data security, regulatory compliance, and privacy.",
            comment: "Link bank: detail subtitle for bank linkage using partner title"
        )

        public static let learnMore = NSLocalizedString("Learn more", comment: "Learn more")

        public static let continueButtonTitle = NSLocalizedString(
            "Continue",
            comment: "Link bank: continue button title"
        )

        public enum GenericFailure {
            public static let title = NSLocalizedString(
                "Oops! Something went wrong.",
                comment: "Yodlee Web Screen: likning bank error state title"
            )

            public static let subtitle = NSLocalizedString(
                "Please try linking your bank again. If this keeps happening, please contact support.",
                comment: "Bank linkage error state subtitle"
            )
            public static let tryAgainButtonTitle = NSLocalizedString(
                "Try Again",
                comment: "Bank linkage error try again button title"
            )
            public static let cancelActionButtonTitle = NSLocalizedString(
                "Cancel",
                comment: "Bank linkage error cancel button title"
            )
        }
    }

    public enum YodleeWebScreen {
        public static let title = NSLocalizedString(
            "Link a Bank",
            comment: "Yodlee Web Screen: Link a Bank title"
        )

        public enum WebViewPendingContent {
            public static let title = NSLocalizedString(
                "Taking you to Yodlee...",
                comment: "Yodlee Web Screen: loading state title"
            )

            public static let subtitle = NSLocalizedString(
                "This could take up to 30 secconds.",
                comment: "Yodlee Web Screen: loading state subtitle"
            )
        }

        public enum LinkingPendingContent {
            public static let title = NSLocalizedString(
                "Updating Your Wallet...",
                comment: "Yodlee Web Screen: likning bank loading state title"
            )
        }

        public enum WebViewSuccessContent {
            public static let title = NSLocalizedString(
                "Bank Linked!",
                comment: "Yodlee Web Screen: linked bank success state title"
            )

            public static let subtitleWithBankName = NSLocalizedString(
                "Your %@ account is now linked to your Blockchain.com Wallet.",
                comment: "Yodlee Web Screen: linked bank success subtitle with custom bank name"
            )

            public static let subtitleGeneric = NSLocalizedString(
                "Your account is now linked to your Blockchain.com Wallet.",
                comment: "Yodlee Web Screen: linked bank success subtitle without bank name"
            )
            public static let mainActionButtonTitle = NSLocalizedString(
                "Continue",
                comment: "Yodlee Web Screen: likning bank success continue button title"
            )
        }

        public enum FailurePendingContent {
            public static let contactSupport = NSLocalizedString(
                " contact support.",
                comment: "Yodlee Web Screen: likning bank contact support."
            )
            public enum Generic {
                public static let title = NSLocalizedString(
                    "Oops! Something went wrong.",
                    comment: "Yodlee Web Screen: likning bank error state title"
                )

                public static let subtitle = NSLocalizedString(
                    "Please try linking your bank again. If this keeps happening, please",
                    comment: "Yodlee Web Screen: likning bank error state subtitle"
                )
                public static let mainActionButtonTitle = NSLocalizedString(
                    "Try Again",
                    comment: "Yodlee Web Screen: likning bank error try again button title"
                )
                public static let cancelActionButtonTitle = NSLocalizedString(
                    "Cancel & Go Back",
                    comment: "Yodlee Web Screen: likning bank error cancel button title"
                )
            }

            public enum AlreadyLinked {
                public static let mainActionButtonTitle = NSLocalizedString(
                    "OK",
                    comment: "Yodlee Web Screen: likning bank error try again button title"
                )
            }

            public enum AccountUnsupported {
                public static let mainActionButtonTitle = NSLocalizedString(
                    "Try a Different Bank",
                    comment: "Yodlee Web Screen: likning bank error try again button title"
                )
            }
        }
    }
}
