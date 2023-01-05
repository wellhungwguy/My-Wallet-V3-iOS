// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BitcoinKit
import Localization
import MoneyKit
import PlatformKit
import PlatformUIKit

struct BitcoinActivityDetailsViewModel: Equatable {

    private typealias LocalizedString = LocalizationConstants.Activity.Details

    struct Confirmation: Equatable {
        fileprivate static let empty: Confirmation = .init(
            needConfirmation: false,
            title: "",
            factor: 1,
            statusBadge: BitcoinActivityDetailsViewModel.statusBadge(needConfirmation: false)
        )
        let needConfirmation: Bool
        let title: String
        let factor: Float
        let statusBadge: BadgeAsset.Value.Interaction.BadgeItem
    }

    let confirmation: Confirmation
    let dateCreated: String
    let to: String
    let from: String
    let cryptoAmount: String
    let value: String
    let fee: String
    let note: String

    init(details: BitcoinActivityItemEventDetails, price: FiatValue?, note: String?) {
        self.confirmation = Confirmation(
            needConfirmation: details.confirmation.needConfirmation,
            title: "\(details.confirmation.confirmations) \(LocalizedString.of) \(details.confirmation.requiredConfirmations) \(LocalizedString.confirmations)",
            factor: details.confirmation.factor,
            statusBadge: BitcoinActivityDetailsViewModel.statusBadge(needConfirmation: details.confirmation.needConfirmation)
        )
        self.dateCreated = DateFormatter.elegantDateFormatter.string(from: details.createdAt)
        self.to = details.to.publicKey
        self.from = details.from.publicKey

        self.cryptoAmount = details.amount.displayString
        if let price {
            self.value = details.amount.convert(using: price).displayString
            self.fee = "\(details.fee.displayString) / \(details.fee.convert(using: price).displayString)"
        } else {
            self.value = ""
            self.fee = details.fee.displayString
        }

        self.note = note ?? ""
    }

    private static func statusBadge(needConfirmation: Bool) -> BadgeAsset.Value.Interaction.BadgeItem {
        if needConfirmation {
            return .init(
                type: .default(accessibilitySuffix: "Pending"),
                description: LocalizedString.pending
            )
        } else {
            return .init(type: .verified, description: LocalizedString.completed)
        }
    }
}
