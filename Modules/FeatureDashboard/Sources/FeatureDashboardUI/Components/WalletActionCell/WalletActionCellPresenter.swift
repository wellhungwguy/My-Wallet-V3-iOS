// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Localization
import MoneyKit
import PlatformKit
import PlatformUIKit

final class WalletActionCellPresenter {

    private typealias AccessibilityId = Accessibility.Identifier.WalletActionSheet
    private typealias LocalizationId = LocalizationConstants.WalletAction.Default

    let badgeImageViewModel: BadgeImageViewModel
    let titleLabelContent: LabelContent
    let descriptionLabelContent: LabelContent
    let action: WalletAction

    init(currencyType: CurrencyType, action: WalletAction) {
        self.action = action

        var templateColor: UIColor = .clear
        var accentColor: UIColor = .clear
        switch currencyType {
        case .crypto(let crypto):
            templateColor = crypto.brandUIColor
            accentColor = crypto.accentColor
        case .fiat(let fiat):
            templateColor = fiat.brandColor
            accentColor = fiat.brandColor.withAlphaComponent(0.15)
        }
        self.badgeImageViewModel = .template(
            image: .local(name: action.imageName, bundle: .platformUIKit),
            templateColor: templateColor,
            backgroundColor: accentColor,
            cornerRadius: .round,
            accessibilityIdSuffix: "\(action.accessibilityId)"
        )

        self.titleLabelContent = .init(
            text: action.name,
            font: .main(.semibold, 16.0),
            color: .textFieldText,
            alignment: .left,
            accessibility: .id(AccessibilityId.Action.title)
        )

        var description: String = ""

        switch action {
        case .activity:
            description = LocalizationId.Activity.description
        case .deposit:
            switch currencyType {
            case .crypto:
                description = String(format: LocalizationId.Deposit.Crypto.description, currencyType.displayCode)
            case .fiat:
                description = LocalizationId.Deposit.Fiat.description
            }
        case .withdraw:
            description = LocalizationId.Withdraw.description
        case .interest:
            description = .init(format: LocalizationId.Interest.description, currencyType.displayCode)
        case .send:
            description = .init(format: LocalizationId.Send.description, currencyType.displayCode)
        case .receive:
            description = .init(format: LocalizationId.Receive.description, currencyType.displayCode)
        case .swap:
            description = .init(format: LocalizationId.Swap.description, currencyType.displayCode)
        case .buy:
            description = LocalizationId.Buy.description
        case .sell:
            description = LocalizationId.Sell.description
        }

        self.descriptionLabelContent = .init(
            text: description,
            font: .main(.medium, 14.0),
            color: .descriptionText,
            alignment: .left,
            accessibility: .id(AccessibilityId.Action.description)
        )
    }
}
