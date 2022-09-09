// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import AnalyticsKit
import DIKit
import PlatformKit
import PlatformUIKit
import SwiftUI
import ToolKit

/// This announcement introduces Bitpay
final class BitpayAnnouncement: OneTimeAnnouncement {

    // MARK: - Properties

    var viewModel: AnnouncementCardViewModel {
        AnnouncementCardViewModel(
            type: type,
            badgeImage: .init(
                image: .local(name: "card-icon-bitpay", bundle: .main),
                contentColor: nil,
                backgroundColor: .clear,
                cornerRadius: .none,
                size: CGSize(width: 115, height: 40)
            ),
            description: LocalizationConstants.AnnouncementCards.Bitpay.description,
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

    let type = AnnouncementType.bitpay
    let analyticsRecorder: AnalyticsEventRecorderAPI

    let dismiss: CardAnnouncementAction
    let recorder: AnnouncementRecorder

    // MARK: - Setup

    init(
        cacheSuite: CacheSuite = resolve(),
        analyticsRecorder: AnalyticsEventRecorderAPI = resolve(),
        errorRecorder: ErrorRecording = CrashlyticsRecorder(),
        dismiss: @escaping CardAnnouncementAction
    ) {
        recorder = AnnouncementRecorder(cache: cacheSuite, errorRecorder: errorRecorder)
        self.analyticsRecorder = analyticsRecorder
        self.dismiss = dismiss
    }
}

// MARK: SwiftUI Preview

#if DEBUG
struct BitpayAnnouncementContainer: UIViewRepresentable {
    typealias UIViewType = AnnouncementCardView

    func makeUIView(context: Context) -> UIViewType {
        let presenter = BitpayAnnouncement(dismiss: {})
        return AnnouncementCardView(using: presenter.viewModel)
    }

    func updateUIView(_ uiView: UIViewType, context: Context) {}
}

struct BitpayAnnouncementContainer_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            BitpayAnnouncementContainer().colorScheme(.light)
        }.previewLayout(.fixed(width: 375, height: 200))
    }
}
#endif
