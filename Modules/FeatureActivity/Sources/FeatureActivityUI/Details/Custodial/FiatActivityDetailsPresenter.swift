// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import AnalyticsKit
import DIKit
import Localization
import PlatformKit
import PlatformUIKit
import RxRelay
import RxSwift
import ToolKit

final class FiatActivityDetailsPresenter: DetailsScreenPresenterAPI {

    // MARK: - Types

    private typealias BadgeItem = BadgeAsset.Value.Interaction.BadgeItem
    private typealias BadgeType = BadgeItem.BadgeType
    private typealias LocalizedString = LocalizationConstants.Activity.Details
    private typealias AccessibilityId = Accessibility.Identifier.Activity.Details

    // MARK: - DetailsScreenPresenterAPI

    let cells: [DetailsScreen.CellType]

    let titleViewRelay: BehaviorRelay<Screen.Style.TitleView> = .init(value: .none)

    let navigationBarAppearance: DetailsScreen.NavigationBarAppearance = .defaultDark

    let navigationBarLeadingButtonAction: DetailsScreen.BarButtonAction = .default

    let navigationBarTrailingButtonAction: DetailsScreen.BarButtonAction = .default

    let reloadRelay: PublishRelay<Void> = .init()

    // MARK: - Private Properties

    private let disposeBag = DisposeBag()

    // MARK: Private Properties (LabelContentPresenting)

    private let fiatAmountLabelPresenter: LabelContentPresenting

    // MARK: Private Properties (Badge Model)

    private let badgesModel = MultiBadgeViewModel()
    private let statusBadge: DefaultBadgeAssetPresenter = .init()

    // MARK: Private Properties (LineItemCellPresenting)

    private let orderIDPresenter: LineItemCellPresenting
    private let dateCreatedPresenter: LineItemCellPresenting
    private let destinationPresenter: LineItemCellPresenting

    // MARK: - Init

    init(
        event: CustodialActivityEvent.Fiat,
        analyticsRecorder: AnalyticsEventRecorderAPI = resolve()
    ) {
        let title: String
        switch (event.type, event.state) {
        case (.deposit, .pending):
            title = LocalizedString.Title.depositing
        case (.deposit, .completed):
            title = LocalizedString.Title.deposited
        case (.deposit, .failed):
            title = LocalizedString.Title.deposit
        case (.withdrawal, .pending):
            title = LocalizedString.Title.withdrawing
        case (.withdrawal, .completed):
            title = LocalizedString.Title.withdrawn
        case (.withdrawal, .failed):
            title = LocalizedString.Title.withdrawal
        }
        titleViewRelay.accept(.text(value: title))

        fiatAmountLabelPresenter = DefaultLabelContentPresenter(
            knownValue: event.amount.displayString,
            descriptors: .h1(accessibilityIdPrefix: "")
        )

        let statusDescription: String
        let badgeType: BadgeType
        switch event.state {
        case .completed:
            statusDescription = LocalizedString.completed
            badgeType = .verified
        case .pending:
            statusDescription = LocalizedString.pending
            badgeType = .default(accessibilitySuffix: statusDescription)
        case .failed:
            statusDescription = LocalizedString.failed
            badgeType = .destructive
        }
        badgesModel.badgesRelay.accept([statusBadge])
        statusBadge.interactor.stateRelay.accept(
            .loaded(
                next: .init(
                    type: badgeType,
                    description: statusDescription
                )
            )
        )

        orderIDPresenter = TransactionalLineItem.orderId(event.identifier).defaultCopyablePresenter(
            analyticsRecorder: analyticsRecorder,
            accessibilityIdPrefix: AccessibilityId.lineItemPrefix
        )

        let date = DateFormatter.elegantDateFormatter.string(from: event.date)
        dateCreatedPresenter = TransactionalLineItem.date(date).defaultPresenter(
            accessibilityIdPrefix: AccessibilityId.lineItemPrefix
        )

        let destination = event.amount.currency.defaultWalletName
        switch event.type {
        case .deposit:
            destinationPresenter = TransactionalLineItem.to(destination).defaultPresenter(
                accessibilityIdPrefix: AccessibilityId.lineItemPrefix
            )
        case .withdrawal:
            destinationPresenter = TransactionalLineItem.from(destination).defaultPresenter(
                accessibilityIdPrefix: AccessibilityId.lineItemPrefix
            )
        }

        cells = [
            .label(fiatAmountLabelPresenter),
            .badges(badgesModel),
            .separator,
            .lineItem(orderIDPresenter),
            .separator,
            .lineItem(dateCreatedPresenter),
            .separator,
            .lineItem(destinationPresenter)
        ]
    }
}
