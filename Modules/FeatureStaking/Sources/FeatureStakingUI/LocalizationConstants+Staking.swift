import Foundation
import enum Localization.LocalizationConstants

// swiftlint:disable line_length

extension LocalizationConstants {

    enum Staking {

        static let title = NSLocalizedString("Staking Considerations", comment: "Title for Staking Considerations")

        static let page = (
            NSLocalizedString(
                """
                The Ethereum roadmap involves several upgrades that will make the network more scalable, more secure, and more sustainable.

                Recently, Ethereum has completed what is called The Merge, meaning that
                """,
                comment: "Staking: Explain to users their funds will be locked when staking their balance, until ETH implements withdraw. Page 1 of 3"
            ),
            NSLocalizedString(
                """
                Once staked, ETH funds can’t be unstaked or transferred for an unspecified period of time.

                This may be up to 6 - 12 months away, but could be even longer.

                Your ETH will also be subject to a bonding period of %@ before it generates rewards.

                These rules are not specific to Blockchain.com. They’re features of the Ethereum network.
                """,
                comment: "Staking: Explain to users their funds will be locked when staking their balance, until ETH implements withdraw. Page 2 of 3"
            ), NSLocalizedString(
                """
                Once staked, ETH funds can’t be unstaked or transferred for an unspecified period of time.

                This may be up to 6 - 12 months away, but could be even longer.

                Your ETH will also be subject to a bonding period of %@ before it generates rewards.

                These rules are not specific to Blockchain.com. They’re features of the Ethereum network.
                """,
                comment: "Staking: Explain to users their funds will be locked when staking their balance, until ETH implements withdraw. Page 3 of 3"
            )
        )

        static let next = NSLocalizedString("Next", comment: "Staking: Next CTA on Disclaimer")
        static let understand = NSLocalizedString("I understand", comment: "Staking: I understand CTA on Disclaimer")
        static let learnMore = NSLocalizedString("Learn More", comment: "Staking: Learn More button on Disclaimer")
        static let withdraw = NSLocalizedString("Withdraw", comment: "Staking: Withdraw Button")
        static let add = NSLocalizedString("Add", comment: "Staking: Add Button")
        static let summaryTitle = NSLocalizedString("%@ Staking Rewards", comment: "Staking: Staking Rewards title")
        static let balance = NSLocalizedString("Balance", comment: "Staking: Balance")
        static let totalEarned = NSLocalizedString("Total Earned", comment: "Staking: Total Earned")
        static let totalStaked = NSLocalizedString("Total Staked", comment: "Staking: Total Staked")
        static let bonding = NSLocalizedString("Bonding", comment: "Staking: Bonding")
        static let currentRate = NSLocalizedString("Current Rate", comment: "Staking: Current Rate")
        static let paymentFrequency = NSLocalizedString("Payment Frequency", comment: "Staking: Payment Frequency")
        static let daily = NSLocalizedString("Daily", comment: "Staking: Daily")
        static let weekly = NSLocalizedString("Weekly", comment: "Staking: Weekly")
        static let monthly = NSLocalizedString("Monthly", comment: "Staking: Monthly")
        static let viewActivity = NSLocalizedString("View Activity", comment: "Staking: View Activity")
        static let inProcess = NSLocalizedString("In process", comment: "Staking: In process")
        static let withdrawDisclaimer = NSLocalizedString("Unstaking and withdrawing ETH will be available when enabled by the Ethereum network.", comment: "Staking: Disclaimer")
    }
}
