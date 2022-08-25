// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import AnalyticsKit
import DIKit
import PlatformKit
import PlatformUIKit
import RxCocoa
import RxSwift
import SwiftUI
import ToolKit

/// Swap 2.0 announcement is a periodic announcement that introduces the user to in-wallet asset trading
final class NewSwapAnnouncement: OneTimeAnnouncement, ActionableAnnouncement {

    // MARK: - Types

    private typealias LocalizedString = LocalizationConstants.AnnouncementCards.NewSwap

    private enum Style {
        case promo
        case eligible
        case notEligible

        var title: String {
            switch self {
            case .promo:
                return LocalizedString.Promo.title
            case .eligible:
                return LocalizedString.Eligible.title
            case .notEligible:
                return LocalizedString.NotEligible.title
            }
        }

        var description: String {
            switch self {
            case .promo:
                return LocalizedString.Promo.description
            case .eligible:
                return LocalizedString.Eligible.description
            case .notEligible:
                return LocalizedString.NotEligible.description
            }
        }

        var cta: String {
            switch self {
            case .promo:
                return LocalizedString.Promo.ctaButton
            case .eligible:
                return LocalizedString.Eligible.ctaButton
            case .notEligible:
                return LocalizedString.NotEligible.ctaButton
            }
        }
    }

    // MARK: - Properties

    var viewModel: AnnouncementCardViewModel {
        let activeStyle = style
        let button = ButtonViewModel.primary(
            with: activeStyle.cta
        )
        button.tapRelay
            .bind { [weak self] in
                guard let self = self else { return }
                self.analyticsRecorder.record(event: self.actionAnalyticsEvent)
                self.action()
                self.dismiss()
            }
            .disposed(by: disposeBag)

        return AnnouncementCardViewModel(
            type: type,
            badgeImage: .init(
                image: .local(name: "card-icon-swap", bundle: .main),
                contentColor: nil,
                backgroundColor: .clear,
                cornerRadius: .none,
                size: .edge(40)
            ),
            title: activeStyle.title,
            description: activeStyle.description,
            buttons: [button],
            dismissState: .dismissible { [weak self] in
                guard let self = self else { return }
                self.analyticsRecorder.record(event: self.dismissAnalyticsEvent)
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

    let type: AnnouncementType = .newSwap
    let analyticsRecorder: AnalyticsEventRecorderAPI
    let dismiss: CardAnnouncementAction
    let recorder: AnnouncementRecorder
    let action: CardAnnouncementAction

    private var style: Style {
        guard isTier1Or2Verified else {
            return .promo
        }
        return isEligibleForSimpleBuy ? .eligible : .notEligible
    }

    private let isEligibleForSimpleBuy: Bool
    private let isTier1Or2Verified: Bool
    private let disposeBag = DisposeBag()

    // MARK: - Setup

    init(
        isEligibleForSimpleBuy: Bool,
        isTier1Or2Verified: Bool,
        cacheSuite: CacheSuite = resolve(),
        analyticsRecorder: AnalyticsEventRecorderAPI = resolve(),
        errorRecorder: ErrorRecording = CrashlyticsRecorder(),
        dismiss: @escaping CardAnnouncementAction,
        action: @escaping CardAnnouncementAction
    ) {
        self.isEligibleForSimpleBuy = isEligibleForSimpleBuy
        self.isTier1Or2Verified = isTier1Or2Verified
        recorder = AnnouncementRecorder(cache: cacheSuite, errorRecorder: errorRecorder)
        self.analyticsRecorder = analyticsRecorder
        self.dismiss = dismiss
        self.action = action
    }
}

// MARK: SwiftUI Preview

#if DEBUG
struct NewSwapAnnouncementContainer: UIViewRepresentable {
    typealias UIViewType = AnnouncementCardView

    func makeUIView(context: Context) -> UIViewType {
        let presenter = NewSwapAnnouncement(
            isEligibleForSimpleBuy: true,
            isTier1Or2Verified: true,
            dismiss: {},
            action: {}
        )
        return AnnouncementCardView(using: presenter.viewModel)
    }

    func updateUIView(_ uiView: UIViewType, context: Context) {}
}

struct NewSwapAnnouncementContainer_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            NewSwapAnnouncementContainer().colorScheme(.light)
        }.previewLayout(.fixed(width: 375, height: 250))
    }
}
#endif
