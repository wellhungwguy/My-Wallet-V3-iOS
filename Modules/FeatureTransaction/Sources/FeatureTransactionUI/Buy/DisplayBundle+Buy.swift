// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import AnalyticsKit
import Localization
import PlatformKit

private class BuyAnalyticsEvent: AnalyticsEvent {
    var name: String = "Buy"
}

extension DisplayBundle {

    static func buy(sourceAccount: SingleAccount, destinationAccount: CryptoAccount) -> DisplayBundle {
        typealias LocalizedString = LocalizationConstants.Transaction
        return DisplayBundle(
            title: LocalizedString.Buy.title + " \(destinationAccount.asset.name)",
            amountDisplayBundle: .init(
                events: .init(
                    min: BuyAnalyticsEvent(),
                    max: BuyAnalyticsEvent()
                ),
                strings: .init(
                    useMin: LocalizedString.Buy.AmountPresenter.LimitView.useMin,
                    useMax: LocalizedString.Buy.AmountPresenter.LimitView.useMax
                ),
                accessibilityIdentifiers: .init()
            )
        )
    }
}
