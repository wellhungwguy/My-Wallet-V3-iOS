// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import AnalyticsKit
import BlockchainComponentLibrary
import DIKit
import PlatformKit
import PlatformUIKit
import RxCocoa
import RxSwift
import SwiftUI
import ToolKit

protocol InterestIdentityVerificationAnnouncementRouting: AnyObject {
    func showInterestDashboardAnnouncementScreen(isKYCVerfied: Bool)
}

/// Interest announcement for announcing Interest Account feature + KYC
final class InterestIdentityVerificationAnnouncement: OneTimeAnnouncement, ActionableAnnouncement {

    private typealias LocalizationId = LocalizationConstants.AnnouncementCards.InterestIdentityVerification

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
                image: .local(name: Icon.interest.name, bundle: .componentLibrary),
                contentColor: .white,
                backgroundColor: .defaultBadge,
                cornerRadius: .round,
                size: .init(edge: 32.0)
            ),
            title: LocalizationId.title,
            description: isKYCVerified ? LocalizationId.Description.kycd : LocalizationId.Description.notKYCd,
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
        [AppMode.trading, AppMode.both]
    }

    var shouldShow: Bool {
        !isDismissed
    }

    let type = AnnouncementType.interestFunds
    let analyticsRecorder: AnalyticsEventRecorderAPI

    let dismiss: CardAnnouncementAction
    let recorder: AnnouncementRecorder

    let action: CardAnnouncementAction

    private let disposeBag = DisposeBag()

    private let isKYCVerified: Bool

    // MARK: - Setup

    init(
        isKYCVerified: Bool,
        cacheSuite: CacheSuite = resolve(),
        analyticsRecorder: AnalyticsEventRecorderAPI = resolve(),
        errorRecorder: ErrorRecording = CrashlyticsRecorder(),
        dismiss: @escaping CardAnnouncementAction,
        action: @escaping CardAnnouncementAction
    ) {
        self.isKYCVerified = isKYCVerified
        recorder = AnnouncementRecorder(cache: cacheSuite, errorRecorder: errorRecorder)
        self.analyticsRecorder = analyticsRecorder
        self.dismiss = dismiss
        self.action = action
    }
}

// MARK: SwiftUI Preview

#if DEBUG
struct InterestIdentityVerificationAnnouncementContainer: UIViewRepresentable {
    typealias UIViewType = AnnouncementCardView

    func makeUIView(context: Context) -> UIViewType {
        let presenter = InterestIdentityVerificationAnnouncement(
            isKYCVerified: true,
            dismiss: {},
            action: {}
        )
        return AnnouncementCardView(using: presenter.viewModel)
    }

    func updateUIView(_ uiView: UIViewType, context: Context) {}
}

struct InterestIdentityVerificationAnnouncementContainer_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            InterestIdentityVerificationAnnouncementContainer().colorScheme(.light)
        }.previewLayout(.fixed(width: 375, height: 250))
    }
}
#endif
