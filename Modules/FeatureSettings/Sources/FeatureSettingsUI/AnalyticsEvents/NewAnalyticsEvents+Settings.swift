// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import AnalyticsKit

extension AnalyticsEvents.New {
    enum Settings: AnalyticsEvent {
        var type: AnalyticsEventType { .nabu }

        case addMobileNumberClicked(origin: Origin)
        case changeMobileNumberClicked
        case notificationClicked
        case walletReferralProgramClicked(origin: String)
        case notificationPreferencesUpdated(emailEnabled: Bool?, smsEnabled: Bool?)
        case settingsCurrencyClicked(currency: String)
        case settingsTradingCurrencyClicked(currency: String)
        case settingsHyperlinkClicked(destination: Destination)

        enum Destination: String, StringRawRepresentable {
            case about = "ABOUT"
            case cookiesPolicy = "COOKIES_POLICY"
            case privacyPolicy = "PRIVACY_POLICY"
            case rateUs = "RATE_US"
            case termsOfService = "TERMS_OF_SERVICE"
        }

        enum Origin: String, StringRawRepresentable {
            case settings = "SETTINGS"
        }

        enum ReferralOrigin: String, StringRawRepresentable {
            case profile
            case portfolio
            case popupsheet
            case deeplink
        }
    }
}
