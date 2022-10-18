// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

extension LocalizationConstants {
    public enum NotificationPreferences {
        public enum NotificationScreen {
            public enum Title {}
            public enum Description {}
        }

        public enum Error {
            public enum Title {}
            public enum Description {}
            public enum GoBackButton {}
            public enum RetryButton {}
        }
    }
}

extension LocalizationConstants.NotificationPreferences.Error.Title {
    public static let titleString = NSLocalizedString(
        "Notification settings failed to load",
        comment: "Error title"
    )
}

extension LocalizationConstants.NotificationPreferences.Error.Description {
    public static let descriptionString = NSLocalizedString(
        "There was a problem fetching your notifications settings. Please reload or try again later.",
        comment: "Error description"
    )
}

extension LocalizationConstants.NotificationPreferences.Error.GoBackButton {
    public static let goBackString = NSLocalizedString(
        "Go Back",
        comment: "secondary button"
    )
}

extension LocalizationConstants.NotificationPreferences.Error.RetryButton {
    public static let tryAgainString = NSLocalizedString(
        "Try again",
        comment: "Primary button"
    )
}

extension LocalizationConstants.NotificationPreferences.NotificationScreen.Title {
    public static let titleString = NSLocalizedString(
        "Notification Preferences",
        comment: "title"
    )
}

extension LocalizationConstants.NotificationPreferences.NotificationScreen.Description {
    public static let descriptionString = NSLocalizedString(
        "Choose how you want to stay informed.",
        comment: "title"
    )
}

extension LocalizationConstants.NotificationPreferences.NotificationScreen {
    public static let requiredString = NSLocalizedString(
        "Required",
        comment: "Required"
    )
}
