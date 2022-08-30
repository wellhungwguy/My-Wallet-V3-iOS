// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import AnalyticsKit
import DIKit
import PlatformKit
import PlatformUIKit
import RxCocoa
import RxSwift
import SwiftUI
import ToolKit

/// Announcement that introduces Cloud Backup
final class CloudBackupAnnouncement: OneTimeAnnouncement, ActionableAnnouncement {

    private typealias LocalizedString = LocalizationConstants.AnnouncementCards.CloudBackup

    // MARK: - Properties

    var viewModel: AnnouncementCardViewModel {
        let button = ButtonViewModel.primary(
            with: LocalizedString.ctaButton,
            background: .primaryButton
        )
        button.tapRelay
            .bind { [weak self] in
                guard let self = self else { return }
                self.analyticsRecorder.record(event: self.actionAnalyticsEvent)
                self.markRemoved()
                self.action()
                self.dismiss()
            }
            .disposed(by: disposeBag)

        return AnnouncementCardViewModel(
            type: type,
            badgeImage: .init(
                image: .local(name: "card-icon-lock", bundle: .main),
                contentColor: nil,
                backgroundColor: .clear,
                cornerRadius: .none,
                size: .edge(40)
            ),
            title: LocalizedString.title,
            description: LocalizedString.description,
            buttons: [button],
            dismissState: .dismissible { [weak self] in
                guard let self = self else { return }
                self.analyticsRecorder.record(event: self.dismissAnalyticsEvent)
                self.markRemoved()
                self.dismiss()
            },
            didAppear: { [weak self] in
                guard let self = self else { return }
                self.analyticsRecorder.record(event: self.didAppearAnalyticsEvent)
            }
        )
    }

    var associatedAppModes: [AppMode] {
        [AppMode.trading, AppMode.legacy]
    }

    var shouldShow: Bool {
        !isDismissed
    }

    let type = AnnouncementType.cloudBackup
    let analyticsRecorder: AnalyticsEventRecorderAPI

    let dismiss: CardAnnouncementAction
    let recorder: AnnouncementRecorder
    let action: CardAnnouncementAction

    private let disposeBag = DisposeBag()

    // MARK: - Setup

    init(
        cacheSuite: CacheSuite = resolve(),
        analyticsRecorder: AnalyticsEventRecorderAPI = resolve(),
        errorRecorder: ErrorRecording = CrashlyticsRecorder(),
        dismiss: @escaping CardAnnouncementAction,
        action: @escaping CardAnnouncementAction
    ) {
        recorder = AnnouncementRecorder(cache: cacheSuite, errorRecorder: errorRecorder)
        self.analyticsRecorder = analyticsRecorder
        self.dismiss = dismiss
        self.action = action
    }
}

// MARK: SwiftUI Preview

#if DEBUG
struct CloudBackupAnnouncementContainer: UIViewRepresentable {
    typealias UIViewType = AnnouncementCardView

    func makeUIView(context: Context) -> UIViewType {
        let presenter = CloudBackupAnnouncement(dismiss: {}, action: {})
        return AnnouncementCardView(using: presenter.viewModel)
    }

    func updateUIView(_ uiView: UIViewType, context: Context) {}
}

struct CloudBackupAnnouncementContainer_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            CloudBackupAnnouncementContainer().colorScheme(.light)
        }.previewLayout(.fixed(width: 375, height: 250))
    }
}
#endif
