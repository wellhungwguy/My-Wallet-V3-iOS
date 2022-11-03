// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import Localization
import PlatformKit
import RxCocoa
import RxSwift

final class WalletViewViewModel {

    private typealias LocalizationIds = LocalizationConstants.Transaction.TargetSource.Radio

    struct Descriptors {
        let accessibilityPrefix: String
    }

    let identifier: AnyHashable
    let accountTypeBadge: BadgeImageViewModel
    let badgeImageViewModel: BadgeImageViewModel
    let nameLabelContent: LabelContent
    let descriptionLabelContent: Driver<LabelContent>

    init(account: SingleAccount, descriptor: Descriptors) {
        let currency = account.currencyType
        identifier = account.identifier

        let image: ImageResource
        if let account = account as? LinkedBankAccount {
            image = account.data.icon.map(ImageResource.remote(url:)) ?? .local(name: "icon-bank", bundle: .platformUIKit)
        } else {
            image = currency.logoResource
        }

        badgeImageViewModel = .default(
            image: image,
            cornerRadius: .round,
            accessibilityIdSuffix: ""
        )
        nameLabelContent = .init(
            text: account.label,
            font: .main(.semibold, 16.0),
            color: .textFieldText,
            alignment: .left,
            accessibility: .id("\(descriptor.accessibilityPrefix).wallet.name")
        )

        switch (account, currency) {
        case (is NonCustodialAccount, .fiat),
             (is TradingAccount, .fiat):
            accountTypeBadge = .empty
        case (is LinkedBankAccount, .fiat):
            accountTypeBadge = .empty
        case (is ExchangeAccount, .crypto):
            accountTypeBadge = .template(
                image: .local(name: "ic-exchange-account", bundle: .platformUIKit),
                templateColor: currency.brandUIColor,
                backgroundColor: .white,
                cornerRadius: .round,
                accessibilityIdSuffix: ""
            )
        case (is NonCustodialAccount, .crypto):
            accountTypeBadge = .template(
                image: .local(name: "ic-private-account", bundle: .platformUIKit),
                templateColor: currency.brandUIColor,
                backgroundColor: .white,
                cornerRadius: .round,
                accessibilityIdSuffix: ""
            )
        case (is TradingAccount, .crypto):
            accountTypeBadge = .template(
                image: .local(name: "ic-trading-account", bundle: .platformUIKit),
                templateColor: currency.brandUIColor,
                backgroundColor: .white,
                cornerRadius: .round,
                accessibilityIdSuffix: ""
            )
        case (is CryptoInterestAccount, .crypto):
            accountTypeBadge = .template(
                image: .local(name: "ic-interest-account", bundle: .platformUIKit),
                templateColor: currency.brandUIColor,
                backgroundColor: .white,
                cornerRadius: .round,
                accessibilityIdSuffix: ""
            )
        default:
            fatalError("Unhandled account type: \(String(describing: account))")
        }

        badgeImageViewModel.marginOffsetRelay.accept(0.0)
        accountTypeBadge.marginOffsetRelay.accept(1.0)

        guard !(account is CryptoExchangeAccount) else {
            // Exchange accounts don't have a balance
            // that we can readily access at this time.
            descriptionLabelContent = .empty()
            return
        }
        descriptionLabelContent = account
            .balance
            .map(\.displayString)
            .map { value in
                .init(
                    text: value,
                    font: .main(.medium, 14.0),
                    color: .descriptionText,
                    alignment: .left,
                    accessibility: .id("\(descriptor.accessibilityPrefix).wallet.balance")
                )
            }
            .asSingle()
            .asDriver(onErrorJustReturn: .empty)
    }
}
