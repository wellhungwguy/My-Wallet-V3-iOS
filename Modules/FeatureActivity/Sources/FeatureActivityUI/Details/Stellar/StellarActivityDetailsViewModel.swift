// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Localization
import MoneyKit
import PlatformKit
import PlatformUIKit
import StellarKit

struct StellarActivityDetailsViewModel: Equatable {

    private typealias LocalizedString = LocalizationConstants.Activity.Details

    let statusBadge: BadgeAsset.Value.Interaction.BadgeItem?
    let dateCreated: String
    let to: String
    let from: String
    let cryptoAmount: String
    let value: String
    let fee: String?
    let memo: String

    init(with details: StellarActivityItemEventDetails, price: FiatValue?) {
        statusBadge = .init(type: .verified, description: LocalizedString.completed)
        dateCreated = DateFormatter.elegantDateFormatter.string(from: details.createdAt)
        to = details.to
        from = details.from

        cryptoAmount = details.cryptoAmount.displayString
        if let price {
            value = details.cryptoAmount.convert(using: price).displayString
        } else {
            value = ""
        }

        if let fee = details.fee {
            if let price {
                self.fee = "\(fee.displayString) / \(fee.convert(using: price).displayString)"
            } else {
                self.fee = fee.displayString
            }
        } else {
            fee = nil
        }

        memo = details.memo ?? LocalizedString.noDescription
    }
}
