// Copyright © Blockchain Luxembourg S.A. All rights reserved.

// swiftlint:disable all

import Foundation

extension LocalizationConstants {
    public enum SimpleBuy {}
}

extension LocalizationConstants.SimpleBuy {
    public enum IneligibleScreen {
        public enum KYCInvalid { /* TODO: */ }
        public enum Country {
            public static let title = NSLocalizedString("Sell Coming Soon for", comment: "Sell Coming Soon for")
            public static let subtitle = NSLocalizedString(
                "Currently, we don't support selling crypto in %@. We'll send you an update when we do.",
                comment: "Currently, we don't support selling crypto in %@. We'll send you an update when we do."
            )
            public static let learnMore = NSLocalizedString("Learn More", comment: "Learn More")
        }
    }

    public enum KYCInvalid {
        public static let title = NSLocalizedString("Unable to Verify Your ID", comment: "")
        public static let subtitle = NSLocalizedString("We were unable to verify your identity. This can happen for a few reasons.", comment: "")
        public static let footer = NSLocalizedString("If you think this was a mistake or would like a manual review of your account, please contact support.", comment: "If you think this was a mistake or would like a manual review of your account, please contact support.")
        public static let disclaimer = NSLocalizedString(
            "If you think this was a mistake or would like a manual review of your account, please contact support.",
            comment: "If you think this was a mistake or would like a manual review of your account, please contact support."
        )
        public static let button = NSLocalizedString("Contact Support", comment: "Contact Support")
        public enum List {
            public enum First {
                public static let title = NSLocalizedString("Invalid ID", comment: "Invalid ID")
                public static let description = NSLocalizedString(
                    "The image or document uploaded did not match the requirements.",
                    comment: "The image or document uploaded did not match the requirements."
                )
            }

            public enum Second {
                public static let title = NSLocalizedString("Information Mismatch", comment: "Information Mismatch")
                public static let description = NSLocalizedString(
                    "All information must appear exactly as it does on your legal documents. note: Please do not use a nickname.",
                    comment: "All information must appear exactly as it does on your legal documents. note: Please do not use a nickname."
                )
            }

            public enum Third {
                public static let title = NSLocalizedString("Blocked by Local Laws", comment: "Blocked by Local Laws")
                public static let description = NSLocalizedString(
                    "At Blockchain.com, we strive to adhere to any and all local laws. Based on your location, we cannot allow the buying or selling digital currencies at this time.",
                    comment: "At Blockchain.com, we strive to adhere to any and all local laws. Based on your location, we cannot allow the buying or selling digital currencies at this time."
                )
            }
        }
    }

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

    public enum Ineligible {
        public static let title = NSLocalizedString(
            "is Not Supported",
            comment: "is Not Supported"
        )
        public static let description = NSLocalizedString(
            "Currently we don’t support buying crypto with",
            comment: "Currently we don’t support buying crypto with"
        )
        public static let changeCurrency = NSLocalizedString(
            "Change Currency",
            comment: "Change Currency"
        )
        public static let viewHome = NSLocalizedString(
            "View Home",
            comment: "View Home"
        )
    }

    public enum PaymentMethodSelectionScreen {
        public static let title = NSLocalizedString(
            "Pay with my...",
            comment: "Simple Buy: Payment method selection screen title"
        )

        public enum NewPaymentButton {
            public static let title = NSLocalizedString(
                "+ Add New",
                comment: "Simple Buy: Add new payment method button selection title"
            )
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
            public static let limitSubtitle = NSLocalizedString(
                "Limit",
                comment: "Simple Buy: Add Payment method selection screen: type subtitle (max amount limit)"
            )
            public static let available = NSLocalizedString(
                "Available",
                comment: "Simple Buy: Add Payment method selection screen: funds type subtitle (max amount limit)"
            )
            public static let addPaymentMethod = NSLocalizedString(
                "Add Payment Method",
                comment: "Simple Buy: Add Payment method selection screen: Add Payment Method"
            )
            public static let selectCashOrCard = NSLocalizedString(
                "Select Cash or Card",
                comment: "Simple Buy: Add Payment method selection screen: select cash or card"
            )
            public static let bankAccount = NSLocalizedString(
                "Bank Account",
                comment: "Simple Buy: Add Payment method selection screen: bank account"
            )
        }
    }

    public enum CryptoSelectionScreen {
        public static let title = NSLocalizedString(
            "Select Currency",
            comment: "Simple Buy: Crypto selection screen title"
        )
        public static let searchBarPlaceholder = NSLocalizedString(
            "Search Currency",
            comment: "Simple Buy: Crypto selection screen search bar placeholder"
        )
    }

    public enum CountrySelectionScreen {
        public static let title = NSLocalizedString(
            "Select Country",
            comment: "Simple Buy: Country selection screen title"
        )
    }

    public enum BuyCryptoScreen {
        public static let title = NSLocalizedString(
            "Buy Crypto",
            comment: "Simple Buy: Buy Crypto screen title"
        )
        public static let previewBuy = NSLocalizedString(
            "Preview Buy",
            comment: "Simple Buy: Buy Crypto Screen - CTA button - Preview Buy"
        )
        public static let paymentMethodTitle = NSLocalizedString(
            "Payment Method",
            comment: "Simple Buy: Buy Crypto Screen - payment method title label"
        )
        public enum LimitView {
            public enum Buy {
                public static let upperLimit = NSLocalizedString(
                    "Up to %@",
                    comment: "Simple Buy: Buy Crypto Screen - Amount upper limit"
                )
                public enum Min {
                    public static let useMin = NSLocalizedString(
                        "%@ Min",
                        comment: "Simple Buy: Buy Crypto Screen - Amount too low suffix"
                    )
                }

                public enum Max {
                    public static let useMax = NSLocalizedString(
                        "%@ Max",
                        comment: "Simple Buy: Buy Crypto Screen - Amount too high suffix"
                    )
                }
            }

            public enum Withdraw {
                public static let upperLimit = NSLocalizedString(
                    "Up to %@",
                    comment: "Simple Buy: Buy Crypto Screen - Amount upper limit"
                )
                public enum Min {
                    public static let useMin = NSLocalizedString(
                        "%@ Min",
                        comment: "Simple Buy: Buy Crypto Screen - Amount too low suffix"
                    )
                }

                public enum Max {
                    public static let useMax = NSLocalizedString(
                        "%@ Max",
                        comment: "Simple Buy: Buy Crypto Screen - Amount too high suffix"
                    )
                }
            }
        }
    }

    public enum SellCryptoScreen {
        public static let from = NSLocalizedString(
            "From: My %@ Trading Account",
            comment: "Sell Crypto: `from` wallet format"
        )
        public static let to = NSLocalizedString(
            "To: My %@ Account",
            comment: "Sell Crypto: `to` wallet format"
        )
        public static let titlePrefix = NSLocalizedString(
            "Sell",
            comment: "Sell Crypto screen title prefix"
        )
        public static let previewSell = NSLocalizedString(
            "Preview Sell",
            comment: "Sell Crypto Screen - CTA button - Preview Sell"
        )
        public static let available = NSLocalizedString(
            "Available",
            comment: "Sell Crypto Screen - Available balance title"
        )
        public static let useMin = NSLocalizedString(
            "%@ Min",
            comment: "Simple Buy: Sell Crypto Screen - Amount too low suffix"
        )
        public static let useMax = NSLocalizedString(
            "Sell Max",
            comment: "Simple Buy: Sell Crypto Screen - Amount too high suffix"
        )
    }

    public enum IntroScreen {
        public enum Sell {
            public static let title = NSLocalizedString("Sell Your Crypto", comment: "Sell Your Crypto")
            public static let description = NSLocalizedString(
                "Verify your identity and sell your crypto.",
                comment: "Verify your identity and sell your crypto."
            )
            public static let verifyIdentity = NSLocalizedString("Verify My Identity", comment: "Verify My Identity")
            public enum List {
                public enum First {
                    public static let title = NSLocalizedString("Verify Your Identity", comment: "Verify Your Identity")
                    public static let description = NSLocalizedString(
                        "To prevent identity theft or fraud, we’ll need to make sure it’s really you by uploading an ID.",
                        comment: "To prevent identity theft or fraud, we’ll need to make sure it’s really you by uploading an ID."
                    )
                }

                public enum Second {
                    public static let title = NSLocalizedString("Sell Crypto for Cash", comment: "Sell Crypto for Cash")
                    public static let description = NSLocalizedString(
                        "Sell your crypto that you have purchased into your cash wallet.",
                        comment: "Sell your crypto that you have purchased into your cash wallet."
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

        public enum BuyCard {
            public static let title = NSLocalizedString(
                "Own Crypto in a Few Minutes",
                comment: "Simple Buy Intro Screen - buy crypto card: title label"
            )
            public static let description = NSLocalizedString(
                "Verify your identity and buy crypto with the fastest experience in the market.",
                comment: "Simple Buy Intro Screen - buy crypto card: description label"
            )
        }

        public static let title = NSLocalizedString(
            "Welcome to Blockchain.com",
            comment: "Simple Buy Intro Screen - title label"
        )
        public static let continueButton = NSLocalizedString(
            "Buy Crypto Now",
            comment: "Simple Buy Intro Screen: Buy CTA button"
        )
        public static let skipButton = NSLocalizedString(
            "Skip",
            comment: "Simple Buy Intro Screen: Skip button"
        )
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

        public enum Funds {

            public static let bankTransfer = NSLocalizedString(
                "Bank Transfer",
                comment: "Bank Transfer"
            )

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

        public enum Title {
            public static let pendingOrderPrefix = NSLocalizedString(
                "Pending",
                comment: "Simple Buy pending order screen title prefix"
            )
            public static let pendingOrderSuffix = NSLocalizedString(
                "Buy",
                comment: "Simple Buy pending order screen title suffix"
            )
            public static let checkout = NSLocalizedString(
                "Transfer Details",
                comment: "Simple Buy checkout screen title"
            )
        }

        public enum Button {
            public static let ok = NSLocalizedString(
                "OK",
                comment: "Simple Buy: Transfer Details Screen - ok button"
            )
            public static let cancel = NSLocalizedString(
                "Cancel Order",
                comment: "Simple Buy: Transfer Details Screen - cancel button"
            )
        }

        public enum TermsLink {
            public enum GBP {
                public static let prefix = NSLocalizedString(
                    "By depositing funds to this account, you agree to ",
                    comment: "Simple Buy - GBP terms and conditions link prefix"
                )
                public static let link = NSLocalizedString(
                    "Terms & Conditions of Modulr",
                    comment: "Simple Buy - GBP terms and conditions link content"
                )
                public static let suffix = NSLocalizedString(
                    ", our banking partner. ",
                    comment: "Simple Buy - GBP terms and conditions link suffix"
                )
            }
        }

        public enum Summary {
            public enum PendingOrder {
                public static let prefix = NSLocalizedString(
                    "Please transfer",
                    comment: "Simple Buy - pending order details summary label"
                )
                public static let middle = NSLocalizedString(
                    "from your bank account to Blockchain.com. Once we receive the funds, we’ll create your",
                    comment: "Simple Buy - pending order details summary label"
                )
                public static let suffix = NSLocalizedString(
                    "buy order.",
                    comment: "Simple Buy - pending order details summary label"
                )
            }

            public enum AnyFiat {
                public static let prefix = NSLocalizedString(
                    "Securely transfer",
                    comment: "Simple Buy - buy summary prefix"
                )
                public static let suffix = NSLocalizedString(
                    "from your bank account to Blockchain.com. Depending on the transfer method and availability of funds, this may take up to 1 business day.",
                    comment: "Simple Buy - buy summary suffix"
                )
            }

            public enum GbpAndUsd {
                public static let prefix = NSLocalizedString(
                    "Securely transfer",
                    comment: "Simple Buy - buy summary prefix"
                )
                public static let suffix = NSLocalizedString(
                    "from your bank to Blockchain.com. Funds are generally available to trade in 1 business day.",
                    comment: "Simple Buy - buy summary suffix"
                )
            }
        }

        public static let disclaimer = NSLocalizedString(
            "Only send funds from a bank account in your name. If not, your deposit could be delayed or rejected.",
            comment: "Simple Buy - disclaimer"
        )

        public enum Cancellation {
            public static let title = NSLocalizedString(
                "Are you sure?",
                comment: "Simple buy - cancellation title"
            )
            public enum Description {
                public static let thisWillRemove = NSLocalizedString(
                    "This will remove your",
                    comment: "This will remove your"
                )
                public static let buyOrder = NSLocalizedString("Buy order.", comment: "Buy order.")
            }

            public static let no = LocalizationConstants.no
            public static let yes = LocalizationConstants.yes
        }
    }

    public enum Checkout {
        public enum Button {
            public static let transferDetails = NSLocalizedString(
                "View Bank Transfer Details",
                comment: "Simple Buy: Order Details - transfer details button"
            )
        }

        public enum Title {
            public static let checkout = NSLocalizedString(
                "Checkout",
                comment: "Checkout screen Title"
            )
            public static let orderDetails = NSLocalizedString(
                "Order Details",
                comment: "Order Details screen Title"
            )
        }

        public enum Summary {
            public static let of = NSLocalizedString(
                "of",
                comment: "Simple buy checkout screen: of (e.g. 100 USD 'of' BTC)"
            )
            public enum Title {
                public static let prefix = NSLocalizedString(
                    "Please review and confirm your ",
                    comment: "Simple buy checkout screen - title prefix"
                )
                public static let suffix = NSLocalizedString(
                    " buy.",
                    comment: "Simple buy checkout screen - title suffix"
                )
            }

            public static let buyButtonTitle = NSLocalizedString(
                "Buy Now",
                comment: "Simple buy checkout screen - buy button prefix"
            )
            public static let sellButtonTitle = NSLocalizedString(
                "Sell Now",
                comment: "Simple buy checkout screen - sell button prefix"
            )
            public static let continueButtonPrefix = NSLocalizedString(
                "OK",
                comment: "Simple buy checkout screen - continue button"
            )
            public static let completePaymentButton = NSLocalizedString(
                "Complete Payment",
                comment: "Simple buy checkout screen - complete payment button"
            )
            public static let approveButtonTitle = NSLocalizedString(
                "Approve",
                comment: "Simple buy checkout screen - approve button"
            )
        }

        public enum Notice {

            public static let funds = NSLocalizedString(
                "Your final amount may change due to market activity.",
                comment: "Simple buy: checkout screen notice label for funds"
            )

            public static let cards = NSLocalizedString(
                "Your final amount might change due to market activity. An initial hold period of 3 days will be applied to your funds.",
                comment: "Simple buy: checkout screen notice label for cards"
            )

            public static let linkedBankCard = NSLocalizedString(
                "Your final amount might change due to market activity. For your security, buy orders with a bank account are subject up to a 14 day holding period. You can Swap or Sell during this time. We will notify you once the funds are fully available.",
                comment: "Simple buy: checkout screen notice label for linked bank transfer"
            )

            public enum BankTransfer {
                public static let prefix = NSLocalizedString(
                    "Once we receive your funds, we’ll start your",
                    comment: "Simple buy: checkout screen notice label prefix"
                )
                public static let suffix = NSLocalizedString(
                    "buy order. Note, your final amount might change to due market activity. Fees may apply.",
                    comment: "Simple buy: checkout screen notice label suffix"
                )
            }
        }

        public enum PendingOrderScreen {
            public enum Loading {
                public enum Buy {
                    public static let titlePrefix = NSLocalizedString(
                        "Buying",
                        comment: "Simple buy: final screen title prefix: Buying 0.00525688 BTC"
                    )
                    public static let subtitle = NSLocalizedString(
                        "We’re completing your purchase now.",
                        comment: "Simple buy: final screen subtitle: We’re completing your purchase now."
                    )
                    public static let learnMore = NSLocalizedString("Learn More", comment: "Learn More")
                }

                public enum Sell {
                    public static let titlePrefix = NSLocalizedString(
                        "Selling",
                        comment: "Simple buy: final screen title prefix: Buying 0.00525688 BTC"
                    )
                    public static let subtitle = NSLocalizedString(
                        "We’re completing your sell now.",
                        comment: "Simple buy: final screen subtitle: We’re completing your purchase now."
                    )
                }
            }

            public enum Success {
                public enum Buy {
                    public static let titleSuffix = NSLocalizedString(
                        "Purchased",
                        comment: "Simple buy: final screen title suffix: E.G 0.0052568 BTC Purchased"
                    )
                    public static let learnMore = NSLocalizedString("Learn more", comment: "Learn more")
                    public static let buyMore = NSLocalizedString("Want to buy more?", comment: "CTA to upgrade to a higher tier.")
                }

                public enum Sell {
                    public static let titleSuffix = NSLocalizedString(
                        "Sold",
                        comment: "Simple buy: final screen title suffix: E.G 0.0052568 BTC Sold"
                    )
                    public static let cash = NSLocalizedString("Cash", comment: "Cash")
                }

                public enum Subtitle {
                    public enum Buy {
                        public static let subtitle = NSLocalizedString(
                            "These funds will be available to sell into your %@ fiat wallet immediately, but you will not be able to send or withdraw these funds from Blockchain.com for up to 3 days.",
                            comment: "These funds will be available to sell into your %@ fiat wallet immediately, but you will not be able to send or withdraw these funds from Blockchain.com for up to 3 days."
                        )
                    }

                    public static let prefix = NSLocalizedString(
                        "Your",
                        comment: "Simple buy: final screen subtitle prefix: Your Asset is now available in your Wallet."
                    )
                    public static let suffix = NSLocalizedString(
                        "is now available in your Wallet.",
                        comment: "Simple buy: final screen subtitle suffix: Your Asset is now available in your Wallet."
                    )
                }
            }

            public enum Timeout {
                public enum Buy {
                    public static let titleSuffix = NSLocalizedString(
                        "Buy In Progress",
                        comment: "Pending active card error screen: title"
                    )
                    public static let achTitleSuffix = NSLocalizedString(
                        "Buy Started",
                        comment: "Pending active ach timeout screen: title"
                    )
                }

                public enum Sell {
                    public static let titleSuffix = NSLocalizedString(
                        "Sell In Progress",
                        comment: "Pending active card error screen: title"
                    )
                }

                public static let subtitle = NSLocalizedString(
                    "We’ll notify you when your order is complete.",
                    comment: "Pending active card error screen: subtitle"
                )
                public static let achSubtitle = NSLocalizedString(
                    "We are completing your purchase now. Expect the funds to be withdrawn from your bank by %@. Check the status of your order at anytime from Wallet’s Activity.",
                    comment: "Pending active ach timeout screen: subtitle"
                )
            }

            public static let button = NSLocalizedString(
                "OK",
                comment: "Simple buy: final screen ok button"
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

    public enum KYCScreen {
        public enum Ineligible {
            public static let title = NSLocalizedString(
                "Coming Soon to Your Region",
                comment: "Simple Buy KYC Screen - ineligible information: title label"
            )
            public static let subtitle = NSLocalizedString(
                "Buying and selling crypto is not available in your region due to local laws. You can still use your wallet to Send, Receive and Store crypto.",
                comment: "Simple Buy KYC Screen - ineligible information: subtitle label"
            )
            public static let button = NSLocalizedString(
                "OK",
                comment: "Simple Buy KYC Screen - ineligible information: button"
            )
        }

        public enum Verifying {
            public static let title = NSLocalizedString(
                "Verifying your information",
                comment: "Simple Buy KYC Screen - verifying information: title label"
            )
            public static let subtitle = NSLocalizedString(
                "Usually takes less than a minute.",
                comment: "Simple Buy KYC Screen - verifying information: subtitle label"
            )
        }

        public enum ManualReview {
            public static let title = NSLocalizedString(
                "Manual Review Required",
                comment: "Simple Buy KYC Screen - manual review: title label"
            )
            public static let subtitle = NSLocalizedString(
                "You’ve successfully submitted your application. A Blockchain Support Member will review your information.",
                comment: "Simple Buy KYC Screen - manual review: subtitle label"
            )
        }

        public enum PendingReview {
            public static let title = NSLocalizedString(
                "Pending Review",
                comment: "Simple Buy KYC Screen - pending review: title label"
            )
            public static let subtitle = NSLocalizedString(
                "You’ve successfully submitted your application. A Blockchain Support Member will review your information.",
                comment: "Simple Buy KYC Screen - pending review: subtitle label"
            )
        }

        public static let title = NSLocalizedString(
            "KYC Status",
            comment: "Simple Buy KYC Screen - title label"
        )
        public static let button = NSLocalizedString(
            "Continue",
            comment: "Simple Buy KYC Screen - button label"
        )
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

            public static let subtitle = NSLocalizedString(
                "This could take up to 30 secconds. Please do not go back or close the app.",
                comment: "Yodlee Web Screen: likning bank loading state subtitle"
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
            public static let contactUs = NSLocalizedString(
                " contact us",
                comment: "Yodlee Web Screen: likning bank contact us."
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

            public enum Timeout {
                public static let title = NSLocalizedString(
                    "Oops! Something went wrong.",
                    comment: "Yodlee Web Screen: likning bank error state title"
                )

                public static let subtitle = NSLocalizedString(
                    "It’s taking too long to link your bank, please try again.",
                    comment: "Yodlee Web Screen: likning bank error state subtitle"
                )
                public static let mainActionButtonTitle = NSLocalizedString(
                    "Try Again",
                    comment: "Yodlee Web Screen: likning bank error try again button title"
                )
                public static let cancelActionButtonTitle = NSLocalizedString(
                    "Cancel",
                    comment: "Yodlee Web Screen: likning bank error cancel button title"
                )
            }

            public enum AlreadyLinked {
                public static let title = NSLocalizedString(
                    "Sorry, that bank account has been linked to the maximum number of Wallets.",
                    comment: "Yodlee Web Screen: likning bank error state title"
                )

                public static let immediately = NSLocalizedString(" immediately.", comment: "immediately")
                public static let subtitle = NSLocalizedString(
                    "To link this bank, please log into your other Wallets and remove it. If this doesnt look right to you, please",
                    comment: "Yodlee Web Screen: likning bank error state subtitle"
                )
                public static let mainActionButtonTitle = NSLocalizedString(
                    "OK",
                    comment: "Yodlee Web Screen: likning bank error try again button title"
                )
            }

            public enum AccountUnsupported {
                public static let title = NSLocalizedString(
                    "Please link a Checking Account.",
                    comment: "Yodlee Web Screen: likning bank error state title"
                )

                public static let subtitle = NSLocalizedString(
                    "Your bank may charge you extra fees if you buy crypto without a checking account.",
                    comment: "Yodlee Web Screen: likning bank error state subtitle"
                )
                public static let mainActionButtonTitle = NSLocalizedString(
                    "Try a Different Bank",
                    comment: "Yodlee Web Screen: likning bank error try again button title"
                )
                public static let cancelActionButtonTitle = NSLocalizedString(
                    "Cancel",
                    comment: "Yodlee Web Screen: likning bank error cancel button title"
                )
            }

            public enum AccountNamesMismatched {
                public static let title = NSLocalizedString(
                    "Is this your bank?",
                    comment: "Yodlee Web Screen: likning bank error state title"
                )

                public static let subtitle = NSLocalizedString(
                    "We noticed the names don’t match. The bank you link must have a matching legal first & last name as your Blockchain.com Account.",
                    comment: "Yodlee Web Screen: likning bank error state subtitle"
                )
                public static let mainActionButtonTitle = NSLocalizedString(
                    "Try a Different Bank",
                    comment: "Yodlee Web Screen: likning bank error try again button title"
                )
                public static let cancelActionButtonTitle = NSLocalizedString(
                    "Cancel",
                    comment: "Yodlee Web Screen: likning bank error cancel button title"
                )
            }
        }
    }
}
