// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import AnalyticsKit

extension SettingsSectionType.CellType {
    var analyticsEvent: [AnalyticsEvent] {
        switch self {
        case .badge(.emailVerification, _):
            return [
                AnalyticsEvents.Settings.settingsEmailClicked,
                AnalyticsEvents.New.Security.emailChangeClicked
            ]
        case .badge(.mobileVerification, _):
            return [AnalyticsEvents.Settings.settingsPhoneClicked]
        case .badge(.recoveryPhrase, _):
            return [
                AnalyticsEvents.Settings.settingsRecoveryPhraseClick,
                AnalyticsEvents.New.Security.recoveryPhraseShown
            ]
        case .clipboard(.walletID):
            return [AnalyticsEvents.Settings.settingsWalletIdCopyClick]
        case .common(.changePassword, _):
            return [AnalyticsEvents.Settings.settingsPasswordClick]
        case .common(.changePIN, _):
            return [
                AnalyticsEvents.Settings.settingsChangePinClick,
                AnalyticsEvents.New.Security.changePinClicked
            ]
        case .common(.rateUs, _):
            return [AnalyticsEvents.New.Settings.settingsHyperlinkClicked(destination: .rateUs)]
        case .common(.termsOfService, _):
            return [AnalyticsEvents.New.Settings.settingsHyperlinkClicked(destination: .termsOfService)]
        case .common(.privacyPolicy, _):
            return [AnalyticsEvents.New.Settings.settingsHyperlinkClicked(destination: .privacyPolicy)]
        case .common(.cookiesPolicy, _):
            return [AnalyticsEvents.New.Settings.settingsHyperlinkClicked(destination: .cookiesPolicy)]
        default:
            return []
        }
    }
}
