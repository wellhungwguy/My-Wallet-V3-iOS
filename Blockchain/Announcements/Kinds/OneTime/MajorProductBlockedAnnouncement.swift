// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import AnalyticsKit
import BlockchainComponentLibrary
import DIKit
import PlatformKit
import PlatformUIKit
import RxSwift
import SwiftUI
import ToolKit

/// This announcement introduces Bitpay
final class MajorProductBlockedAnnouncement: OneTimeAnnouncement, ActionableAnnouncement {

    private typealias LocalizedString = LocalizationConstants.AnnouncementCards.MajorProductBlocked

    // MARK: - Properties

    var viewModel: AnnouncementCardViewModel {
        let button = ButtonViewModel.primary(
            with: LocalizedString.ctaButtonLearnMore,
            background: .primaryButton
        )

        button
            .tapRelay
            .bind { [self] in
                analyticsRecorder.record(event: actionAnalyticsEvent)
                action()
            }
            .disposed(by: disposeBag)

        return AnnouncementCardViewModel(
            type: type,
            badgeImage: .init(
                image: .local(name: "card-icon-sanctions", bundle: .main),
                contentColor: nil,
                backgroundColor: .clear,
                cornerRadius: .none,
                size: CGSize(width: 40, height: 40)
            ),
            title: LocalizedString.title,
            description: announcementMessage ?? LocalizedString.defaultMessage,
            buttons: showLearnMoreButton ? [button] : [],
            dismissState: .dismissible { [self] in
                analyticsRecorder.record(event: dismissAnalyticsEvent)
                markRemoved()
                dismiss()
            },
            didAppear: { [self] in
                analyticsRecorder.record(event: didAppearAnalyticsEvent)
            }
        )
    }

    var shouldShow: Bool {
        announcementMessage != nil && !isDismissed
    }

    let type = AnnouncementType.majorProductBlocked
    let analyticsRecorder: AnalyticsEventRecorderAPI

    var action: CardAnnouncementAction
    let dismiss: CardAnnouncementAction
    let recorder: AnnouncementRecorder

    // MARK: Localize

    let announcementMessage: String?
    let showLearnMoreButton: Bool

    private let disposeBag = DisposeBag()

    // MARK: - Setup

    init(
        cacheSuite: CacheSuite = resolve(),
        announcementMessage: String?,
        analyticsRecorder: AnalyticsEventRecorderAPI = resolve(),
        errorRecorder: ErrorRecording = CrashlyticsRecorder(),
        dismiss: @escaping CardAnnouncementAction,
        action: @escaping CardAnnouncementAction,
        showLearnMoreButton: Bool
    ) {
        recorder = AnnouncementRecorder(cache: cacheSuite, errorRecorder: errorRecorder)
        self.analyticsRecorder = analyticsRecorder
        self.announcementMessage = announcementMessage
        self.dismiss = dismiss
        self.action = action
        self.showLearnMoreButton = showLearnMoreButton
    }
}
