// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit
import FeatureActivityDomain
import Localization
import PlatformKit
import PlatformUIKit

final class ActivityMessageViewModel {

    let titleLabelContent: LabelContent
    let descriptionLabelContent: LabelContent
    let cryptoAmountLabelContent: LabelContent
    let sharedWithLabelContent: LabelContent
    let image: UIImage?
    let logoImage: ImageViewContent
    let badgeImageViewModel: BadgeImageViewModel

    init?(
        event: ActivityItemEvent,
        transactionDetailService: TransactionDetailServiceAPI = resolve()
    ) {
        guard case .transactional(let transaction) = event else { return nil }
        var title = ""
        var imageName = ""
        let currency = transaction.currency
        switch transaction.type {
        case .send:
            title = "\(LocalizationConstants.Activity.MainScreen.Item.send) \(currency.name)"
            imageName = "send-icon"
        case .receive:
            title = "\(LocalizationConstants.Activity.MainScreen.Item.receive) \(currency.name)"
            imageName = "receive-icon"
        }

        self.sharedWithLabelContent = .init(
            text: LocalizationConstants.Activity.MainScreen.MessageView.sharedWithBlockchain,
            font: .main(.semibold, 8.0),
            color: .descriptionText,
            alignment: .right,
            accessibility: .none
        )

        self.badgeImageViewModel = .template(
            image: .local(name: imageName, bundle: .platformUIKit),
            templateColor: currency.brandUIColor,
            backgroundColor: currency.accentColor,
            cornerRadius: .round,
            accessibilityIdSuffix: ""
        )
        badgeImageViewModel.marginOffsetRelay.accept(0.0)

        self.titleLabelContent = .init(
            text: title,
            font: .main(.semibold, 16.0),
            color: .textFieldText,
            alignment: .left,
            accessibility: .none
        )

        self.descriptionLabelContent = .init(
            text: DateFormatter.medium.string(from: event.creationDate),
            font: .main(.medium, 14.0),
            color: .descriptionText,
            alignment: .left,
            accessibility: .none
        )

        let transactionHash = transaction.transactionHash
        guard let url = transactionDetailService.transactionDetailURL(
            for: transactionHash,
            cryptoCurrency: transaction.currency
        ) else { return nil }
        self.image = QRCode(string: url)?.image

        self.logoImage = .init(
            imageResource: .local(name: "logo-blockchain", bundle: .main),
            accessibility: .none,
            renderingMode: .normal
        )
        self.cryptoAmountLabelContent = .init(
            text: event.inputAmount.toDisplayString(includeSymbol: true),
            font: .main(.semibold, 14.0),
            color: .descriptionText,
            alignment: .left,
            accessibility: .none
        )
    }
}
