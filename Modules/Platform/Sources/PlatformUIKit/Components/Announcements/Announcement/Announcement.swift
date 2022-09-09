// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import AnalyticsKit
import BlockchainNamespace

/// Protocol for an announcement that is shown to the user. These are typically
/// used for new products and features that we launch in the wallet.
public protocol Announcement {

    /// Indicates whether the announcement should show.
    /// Should be overridden by the inheriting concrete type.
    var shouldShow: Bool { get }

    /// The view model of the announcement card
    var viewModel: AnnouncementCardViewModel { get }

    /// The type of the announcement
    var type: AnnouncementType { get }

    /// The analytics recorder
    var analyticsRecorder: AnalyticsEventRecorderAPI { get }

    /// An analytics event for appearance
    var didAppearAnalyticsEvent: AnalyticsEvents.Announcement { get }

    // App mode that can display the announcement
    var associatedAppModes: [AppMode] { get }
}

extension Announcement {
    public var didAppearAnalyticsEvent: AnalyticsEvents.Announcement {
        .cardShown(type: type)
    }
}
