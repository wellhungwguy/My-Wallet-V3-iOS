// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import AnalyticsKit
import DIKit
import PlatformKit
import PlatformUIKit
import RxCocoa
import RxSwift
import SwiftUI
import ToolKit

/// Card announcement for announcing Cash feature.
/// Should only show if the user has KYC'd and has not
/// linked a bank.
final class FiatFundsLinkBankAnnouncement: OneTimeAnnouncement, ActionableAnnouncement {

    private typealias LocalizationId = LocalizationConstants.AnnouncementCards.FiatFundsLinkBank

    // MARK: - Properties

    var viewModel: AnnouncementCardViewModel {
        let button = ButtonViewModel.primary(
            with: LocalizationId.linkABank,
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
                image: .local(name: "icon-bank", bundle: .platformUIKit),
                contentColor: .secondary,
                backgroundColor: .white,
                cornerRadius: .none,
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
        shouldShowLinkBankAnnouncement && !isDismissed
    }

    let type = AnnouncementType.fiatFundsKYC
    let analyticsRecorder: AnalyticsEventRecorderAPI

    let dismiss: CardAnnouncementAction
    let recorder: AnnouncementRecorder

    let action: CardAnnouncementAction

    private let disposeBag = DisposeBag()

    private let shouldShowLinkBankAnnouncement: Bool

    // MARK: - Setup

    init(
        shouldShowLinkBankAnnouncement: Bool,
        cacheSuite: CacheSuite = resolve(),
        analyticsRecorder: AnalyticsEventRecorderAPI = resolve(),
        errorRecorder: ErrorRecording = CrashlyticsRecorder(),
        dismiss: @escaping CardAnnouncementAction,
        action: @escaping CardAnnouncementAction
    ) {
        self.shouldShowLinkBankAnnouncement = shouldShowLinkBankAnnouncement
        recorder = AnnouncementRecorder(cache: cacheSuite, errorRecorder: errorRecorder)
        self.analyticsRecorder = analyticsRecorder
        self.dismiss = dismiss
        self.action = action
    }
}

// MARK: SwiftUI Preview

#if DEBUG
struct FiatFundsLinkBankAnnouncementContainer: UIViewRepresentable {
    typealias UIViewType = AnnouncementCardView

    func makeUIView(context: Context) -> UIViewType {
        let presenter = FiatFundsLinkBankAnnouncement(
            shouldShowLinkBankAnnouncement: true,
            dismiss: {},
            action: {}
        )
        return AnnouncementCardView(using: presenter.viewModel)
    }

    func updateUIView(_ uiView: UIViewType, context: Context) {}
}

struct FiatFundsLinkBankAnnouncementContainer_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            FiatFundsLinkBankAnnouncementContainer().colorScheme(.light)
        }.previewLayout(.fixed(width: 375, height: 250))
    }
}
#endif
