// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import AnalyticsKit
import DIKit
import PlatformKit
import PlatformUIKit
import RxCocoa
import RxSwift
import SwiftUI
import ToolKit

/// Enable 2-FA announcement
final class Enable2FAAnnouncement: PeriodicAnnouncement, ActionableAnnouncement {

    // MARK: - Properties

    var viewModel: AnnouncementCardViewModel {
        let button = ButtonViewModel.primary(
            with: LocalizationConstants.AnnouncementCards.TwoFA.ctaButton
        )
        button.tapRelay
            .bind { [weak self] in
                guard let self = self else { return }
                self.analyticsRecorder.record(event: self.actionAnalyticsEvent)
                self.markDismissed()
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
            title: LocalizationConstants.AnnouncementCards.TwoFA.title,
            description: LocalizationConstants.AnnouncementCards.TwoFA.description,
            buttons: [button],
            dismissState: .dismissible { [weak self] in
                guard let self = self else { return }
                self.analyticsRecorder.record(event: self.dismissAnalyticsEvent)
                self.markDismissed()
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
        guard shouldEnable2FA else {
            return false
        }
        return !isDismissed
    }

    let type = AnnouncementType.twoFA
    let analyticsRecorder: AnalyticsEventRecorderAPI

    let dismiss: CardAnnouncementAction
    let recorder: AnnouncementRecorder

    let action: CardAnnouncementAction

    let appearanceRules: PeriodicAnnouncementAppearanceRules

    private let shouldEnable2FA: Bool

    private let disposeBag = DisposeBag()

    // MARK: - Setup

    init(
        shouldEnable2FA: Bool,
        cacheSuite: CacheSuite = resolve(),
        reappearanceTimeInterval: TimeInterval,
        analyticsRecorder: AnalyticsEventRecorderAPI = resolve(),
        errorRecorder: ErrorRecording = CrashlyticsRecorder(),
        dismiss: @escaping CardAnnouncementAction,
        action: @escaping CardAnnouncementAction
    ) {
        self.shouldEnable2FA = shouldEnable2FA
        recorder = AnnouncementRecorder(cache: cacheSuite, errorRecorder: errorRecorder)
        appearanceRules = PeriodicAnnouncementAppearanceRules(recessDurationBetweenDismissals: reappearanceTimeInterval)
        self.analyticsRecorder = analyticsRecorder
        self.dismiss = dismiss
        self.action = action
    }
}

// MARK: SwiftUI Preview

#if DEBUG
struct Enable2FAAnnouncementContainer: UIViewRepresentable {
    typealias UIViewType = AnnouncementCardView

    func makeUIView(context: Context) -> UIViewType {
        let presenter = Enable2FAAnnouncement(
            shouldEnable2FA: true,
            reappearanceTimeInterval: 0,
            dismiss: {},
            action: {}
        )
        return AnnouncementCardView(using: presenter.viewModel)
    }

    func updateUIView(_ uiView: UIViewType, context: Context) {}
}

struct Enable2FAAnnouncementContainer_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            Enable2FAAnnouncementContainer().colorScheme(.light)
        }.previewLayout(.fixed(width: 375, height: 250))
    }
}
#endif
