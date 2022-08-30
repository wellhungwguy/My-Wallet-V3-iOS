// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import AnalyticsKit
import DIKit
import PlatformKit
import PlatformUIKit
import RxCocoa
import RxSwift
import SwiftUI
import ToolKit

/// Card announcement for announcing Cash feature + KYC
final class CashIdentityVerificationAnnouncement: OneTimeAnnouncement, ActionableAnnouncement {

    private typealias LocalizationId = LocalizationConstants.AnnouncementCards.CashIdentityVerification

    // MARK: - Properties

    var viewModel: AnnouncementCardViewModel {
        let button = ButtonViewModel.primary(
            with: LocalizationId.learnMore,
            background: .primaryButton
        )
        button.tapRelay
            .bindAndCatch(weak: self, onNext: { _ in
                // TODO: Analytics
                self.markRemoved()
                self.action()
                self.dismiss()
            })
            .disposed(by: disposeBag)
        return .init(
            type: type,
            badgeImage: .init(
                image: .local(name: "icon-gbp", bundle: .platformUIKit),
                contentColor: .white,
                backgroundColor: .fiat,
                cornerRadius: .roundedLow,
                size: .edge(32)
            ),
            title: LocalizationId.title,
            description: LocalizationId.description,
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
        guard shouldShowCashIdentityAnnouncement else {
            return false
        }
        return !isDismissed
    }

    let type = AnnouncementType.fiatFundsNoKYC
    let analyticsRecorder: AnalyticsEventRecorderAPI

    let dismiss: CardAnnouncementAction
    let recorder: AnnouncementRecorder

    let action: CardAnnouncementAction

    private let disposeBag = DisposeBag()

    private let shouldShowCashIdentityAnnouncement: Bool

    // MARK: - Setup

    init(
        shouldShowCashIdentityAnnouncement: Bool,
        cacheSuite: CacheSuite = resolve(),
        analyticsRecorder: AnalyticsEventRecorderAPI = resolve(),
        errorRecorder: ErrorRecording = CrashlyticsRecorder(),
        dismiss: @escaping CardAnnouncementAction,
        action: @escaping CardAnnouncementAction
    ) {
        self.shouldShowCashIdentityAnnouncement = shouldShowCashIdentityAnnouncement
        recorder = AnnouncementRecorder(cache: cacheSuite, errorRecorder: errorRecorder)
        self.analyticsRecorder = analyticsRecorder
        self.dismiss = dismiss
        self.action = action
    }
}

// MARK: SwiftUI Preview

#if DEBUG
struct CashIdentityVerificationAnnouncementContainer: UIViewRepresentable {
    typealias UIViewType = AnnouncementCardView

    func makeUIView(context: Context) -> UIViewType {
        let presenter = CashIdentityVerificationAnnouncement(
            shouldShowCashIdentityAnnouncement: true,
            dismiss: {},
            action: {}
        )
        return AnnouncementCardView(using: presenter.viewModel)
    }

    func updateUIView(_ uiView: UIViewType, context: Context) {}
}

struct CashIdentityVerificationAnnouncementContainer_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            CashIdentityVerificationAnnouncementContainer().colorScheme(.light)
        }.previewLayout(.fixed(width: 375, height: 250))
    }
}
#endif
