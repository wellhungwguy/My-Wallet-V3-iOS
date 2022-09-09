// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import AnalyticsKit
import DIKit
import PlatformKit
import PlatformUIKit
import RxSwift
import SwiftUI
import ToolKit

private typealias Localization = LocalizationConstants.AnnouncementCards.UKEntitySwap

final class UKEntitySwitchAnnouncement: OneTimeAnnouncement, ActionableAnnouncement {

    let userCountry: Country?
    let action: CardAnnouncementAction
    let dismiss: CardAnnouncementAction

    let recorder: AnnouncementRecorder
    let analyticsRecorder: AnalyticsEventRecorderAPI

    let type: AnnouncementType = .ukEntitySwitch

    var viewModel: AnnouncementCardViewModel {
        let dismissClosure = { [weak self] in
            self?.markRemoved()
            self?.dismiss()
        }

        let actionClosure = { [weak self] in
            self?.action()
            dismissClosure()
        }

        let primaryButton: ButtonViewModel = .primary(with: Localization.ctaButtonPrimary)
        primaryButton.tapRelay
            .subscribe(onNext: dismissClosure)
            .disposed(by: disposeBag)

        let secondaryButton: ButtonViewModel = .secondary(with: Localization.ctaButtonSecondary)
        secondaryButton.tapRelay
            .subscribe(onNext: actionClosure)
            .disposed(by: disposeBag)

        return AnnouncementCardViewModel(
            type: type,
            title: Localization.title,
            description: Localization.description,
            buttons: [
                secondaryButton,
                primaryButton
            ],
            dismissState: .dismissible(dismissClosure)
        )
    }

    var associatedAppModes: [AppMode] {
        [AppMode.trading, AppMode.both]
    }

    var shouldShow: Bool {
        !isDismissed && userCountry == .GB
    }

    private let disposeBag = DisposeBag()

    init(
        userCountry: Country?,
        dismiss: @escaping CardAnnouncementAction,
        action: @escaping CardAnnouncementAction,
        cacheSuite: CacheSuite = resolve(),
        errorRecorder: ErrorRecording = resolve(),
        analyticsRecorder: AnalyticsEventRecorderAPI = resolve()
    ) {
        self.userCountry = userCountry ?? .current
        self.action = action
        self.dismiss = dismiss
        self.analyticsRecorder = analyticsRecorder
        recorder = AnnouncementRecorder(
            cache: cacheSuite,
            errorRecorder: errorRecorder
        )
    }
}

// MARK: SwiftUI Preview

#if DEBUG
struct UKEntitySwitchAnnouncementContainer: UIViewRepresentable {

    typealias UIViewType = AnnouncementCardView

    let dismiss: () -> Void
    let action: () -> Void

    func makeUIView(context: Context) -> UIViewType {
        let presenter = UKEntitySwitchAnnouncement(
            userCountry: .GB,
            dismiss: dismiss,
            action: action
        )
        return AnnouncementCardView(using: presenter.viewModel)
    }

    func updateUIView(_ uiView: UIViewType, context: Context) {}
}

struct UKEntitySwitchAnnouncementContainer_Previews: PreviewProvider {

    struct UKEntitySwitchAnnouncementPreviewWrapper: View {

        private enum AlertInfo: String, Identifiable {
            case dismissed
            case tapped

            var id: String {
                rawValue
            }

            var title: String {
                let text: String
                switch self {
                case .dismissed:
                    text = "Dismissed"
                case .tapped:
                    text = "Tapped"
                }
                return text
            }
        }

        @State private var alertInfo: AlertInfo?

        var body: some View {
            VStack {
                UKEntitySwitchAnnouncementContainer(
                    dismiss: {
                        alertInfo = .dismissed
                    },
                    action: {
                        alertInfo = .tapped
                    }
                )
                Spacer()
            }
            .alert(item: $alertInfo) { alertInfo in
                Alert(
                    title: Text(alertInfo.title),
                    message: nil,
                    dismissButton: .cancel()
                )
            }
        }
    }

    static var previews: some View {
        Group {
            UKEntitySwitchAnnouncementPreviewWrapper()
        }
    }
}
#endif
