// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import AnalyticsKit
import DIKit
import FeatureCryptoDomainDomain
import Localization
import PlatformUIKit
import RxSwift
import ToolKit

final class CardIssuingWaitlistAnnouncement: PersistentAnnouncement, ActionableAnnouncement {

    static let waitlistUrl = "https://www.blockchain.com/card/"

    // MARK: - Types

    private typealias L10n = LocalizationConstants.AnnouncementCards.CardIssuingWaitlist

    // MARK: - Properties

    var viewModel: AnnouncementCardViewModel {
        let button = ButtonViewModel.primary(
            with: L10n.button,
            background: .primaryButton
        )
        button.tapRelay
            .bind { [weak self] in
                guard let self else { return }
                self.analyticsRecorder.record(
                    event: AnalyticsEvents.Announcement.cardActioned(type: .claimFreeCryptoDomain)
                )
                self.action()
                self.dismiss()
            }
            .disposed(by: disposeBag)
        return AnnouncementCardViewModel(
            type: type,
            badgeImage: .init(
                image: .local(name: "card-issuing", bundle: .main),
                contentColor: nil,
                backgroundColor: .clear,
                cornerRadius: .none,
                size: .edge(32)
            ),
            title: L10n.title,
            description: L10n.description,
            buttons: [button],
            dismissState: .dismissible { [weak self] in
                guard let self else { return }
                self.analyticsRecorder.record(
                    event: AnalyticsEvents.Announcement.cardDismissed(type: .claimFreeCryptoDomain)
                )
                self.dismiss()
            },
            didAppear: { [weak self] in
                guard let self else { return }
                self.analyticsRecorder.record(
                    event: AnalyticsEvents.Announcement.cardShown(type: .claimFreeCryptoDomain)
                )
            }
        )
    }

    var associatedAppModes: [AppMode] {
        [AppMode.trading, AppMode.universal]
    }

    var shouldShow: Bool {
        cardIssuingEligible
    }

    let type = AnnouncementType.claimFreeCryptoDomain
    let analyticsRecorder: AnalyticsEventRecorderAPI
    let action: CardAnnouncementAction
    let dismiss: CardAnnouncementAction

    private let cardIssuingEligible: Bool
    private let disposeBag = DisposeBag()

    // MARK: - Setup

    init(
        cardIssuingEligible: Bool,
        analyticsRecorder: AnalyticsEventRecorderAPI = resolve(),
        action: @escaping CardAnnouncementAction,
        dismiss: @escaping CardAnnouncementAction
    ) {
        self.analyticsRecorder = analyticsRecorder
        self.action = action
        self.dismiss = dismiss
        self.cardIssuingEligible = cardIssuingEligible
    }
}
