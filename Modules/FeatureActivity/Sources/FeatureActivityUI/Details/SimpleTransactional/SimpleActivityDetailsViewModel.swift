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
        statusBadge = .init(type: .verified, description: LocalizedString.completed)
        dateCreated = DateFormatter.elegantDateFormatter.string(from: event.creationDate)
        to = event.sourceAddress ?? ""
        from = event.destinationAddress ?? ""

        cryptoAmount = event.amount.displayString
        if let price = price {
            value = event.amount.convert(using: price).displayString
        } else {
            value = ""
        }

        if let price = price {
            let feeFiat = event.fee.convert(using: price)
            fee = "\(event.fee.displayString) / \(feeFiat.displayString)"
        } else {
            fee = event.fee.displayString
        }

        memo = event.memo ?? LocalizedString.noDescription
    }
}
