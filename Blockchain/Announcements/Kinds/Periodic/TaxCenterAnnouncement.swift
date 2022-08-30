// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import AnalyticsKit
import DIKit
import PlatformKit
import PlatformUIKit
import RxCocoa
import RxSwift
import SwiftUI
import ToolKit

/// Announcement that introduces Tax Center
final class TaxCenterAnnouncement: PeriodicAnnouncement {

    private typealias LocalizedString = LocalizationConstants.AnnouncementCards.TaxCenter

    // MARK: - Properties

    var viewModel: AnnouncementCardViewModel {
        let button = ButtonViewModel.primary(
            with: LocalizedString.ctaButton,
            background: .primaryButton
        )
        button.tapRelay
            .bind { [weak self] in
                guard let self = self else { return }
                self.analyticsRecorder.record(event: self.dismissAnalyticsEvent)
                self.markDismissed()
                self.dismiss()
            }
            .disposed(by: disposeBag)

        return AnnouncementCardViewModel(
            type: type,
            badgeImage: .init(
                image: .local(name: "card-icon-tax-center", bundle: .main),
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
        guard userCountry == .US else {
            return false
        }
        return !isDismissed
    }

    let type = AnnouncementType.taxCenter
    let analyticsRecorder: AnalyticsEventRecorderAPI

    let dismiss: CardAnnouncementAction
    let recorder: AnnouncementRecorder
    let userCountry: Country?

    let appearanceRules: PeriodicAnnouncementAppearanceRules

    private let disposeBag = DisposeBag()

    // MARK: - Setup

    init(
        userCountry: Country?,
        cacheSuite: CacheSuite = resolve(),
        analyticsRecorder: AnalyticsEventRecorderAPI = resolve(),
        errorRecorder: ErrorRecording = CrashlyticsRecorder(),
        reappearanceTimeInterval: TimeInterval,
        dismiss: @escaping CardAnnouncementAction
    ) {
        recorder = AnnouncementRecorder(cache: cacheSuite, errorRecorder: errorRecorder)
        self.userCountry = userCountry ?? .current
        self.analyticsRecorder = analyticsRecorder
        self.dismiss = dismiss
        appearanceRules = PeriodicAnnouncementAppearanceRules(
            recessDurationBetweenDismissals: reappearanceTimeInterval,
            maxDismissalCount: 1
        )
    }
}

// MARK: SwiftUI Preview

#if DEBUG
struct TaxCenterAnnouncementContainer: UIViewRepresentable {
    typealias UIViewType = AnnouncementCardView

    func makeUIView(context: Context) -> UIViewType {
        let presenter = TaxCenterAnnouncement(
            userCountry: .US,
            reappearanceTimeInterval: 0,
            dismiss: {}
        )
        return AnnouncementCardView(using: presenter.viewModel)
    }

    func updateUIView(_ uiView: UIViewType, context: Context) {}
}

struct TaxCenterAnnouncementContainer_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            TaxCenterAnnouncementContainer().colorScheme(.light)
        }.previewLayout(.fixed(width: 375, height: 250))
    }
}
#endif
