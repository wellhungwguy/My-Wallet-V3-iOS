import Foundation
import enum Localization.LocalizationConstants

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
    }
}
