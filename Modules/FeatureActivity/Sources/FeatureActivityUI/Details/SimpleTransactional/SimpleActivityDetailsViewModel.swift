// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Localization
import MoneyKit
import PlatformKit
import PlatformUIKit

struct SimpleActivityDetailsViewModel: Equatable {

    private typealias LocalizedString = LocalizationConstants.Activity.Details

    let statusBadge: BadgeAsset.Value.Interaction.BadgeItem?
    let dateCreated: String
    let to: String
    let from: String
    let cryptoAmount: String
    let value: String
    let fee: String?
    let memo: String

    init(with event: SimpleTransactionalActivityItemEvent, price: FiatValue?) {
        self.statusBadge = .init(type: .verified, description: LocalizedString.completed)
        self.dateCreated = DateFormatter.elegantDateFormatter.string(from: event.creationDate)
        self.to = event.sourceAddress ?? ""
        self.from = event.destinationAddress ?? ""

        self.cryptoAmount = event.amount.displayString
        if let price {
            self.value = event.amount.convert(using: price).displayString
        } else {
            self.value = ""
        }

        if let price {
            let feeFiat = event.fee.convert(using: price)
            self.fee = "\(event.fee.displayString) / \(feeFiat.displayString)"
        } else {
            self.fee = event.fee.displayString
        }

        self.memo = event.memo ?? LocalizedString.noDescription
    }
}
