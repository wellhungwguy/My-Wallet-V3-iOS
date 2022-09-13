// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Localization

extension LocalizationConstants {
    enum AppUpgrade {
        enum Button {}
        enum Title {}
        enum Subtitle {}
    }
}

extension LocalizationConstants.AppUpgrade.Button {
    static let skip = NSLocalizedString(
        "I’ll Do This Later",
        comment: "App Upgrade View: Skip button title"
    )
    static let update = NSLocalizedString(
        "Update App",
        comment: "App Upgrade View: Update button title"
    )
    static let status = NSLocalizedString(
        "View Status",
        comment: "App Upgrade View: See system status button title"
    )
    static let goToWeb = NSLocalizedString(
        "Go to Web",
        comment: "App Upgrade View: 'Go to web' button title"
    )
}

extension LocalizationConstants.AppUpgrade.Title {
    static let update = NSLocalizedString(
        "Time to Update!",
        comment: "App Upgrade View: Update title"
    )
    static let maintenance = NSLocalizedString(
        "Down for Maintenance",
        comment: "App Upgrade View: Maintenance title"
    )
    static let unsupportedOS = NSLocalizedString(
        "Your OS is Not Supported",
        comment: "App Upgrade View: Unsupported OS title"
    )
}

extension LocalizationConstants.AppUpgrade.Subtitle {
    static let update = NSLocalizedString(
        "We’ve added awesome new features, security updates, and more.",
        comment: "App Upgrade View: Update title"
    )
    static let appMaintenance = NSLocalizedString(
        "The app is currently under maintenance. Your funds are safe and you can always access your wallet on the web.",
        comment: "App Upgrade View: App Maintenance title"
    )
    static let maintenance = NSLocalizedString(
        "Our systems are currently unavailable. Don’t worry, your funds are safe.",
        comment: "App Upgrade View: Maintenance title"
    )
    static let unsupportedOS = NSLocalizedString(
        "It looks like you are not on the latest version of your operating system. Please update to continue using our mobile app.",
        comment: "App Upgrade View: Unsupported OS title"
    )
}
