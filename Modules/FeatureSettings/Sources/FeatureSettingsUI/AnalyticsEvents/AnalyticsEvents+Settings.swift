// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import AnalyticsKit

extension AnalyticsEvents {
    enum Settings: AnalyticsEvent {
        case settingsEmailClicked
        case settingsPhoneClicked
        case settingsWebWalletLoginClick
        case settingsSwapLimitClicked
        case settingsCloudBackupSwitch(value: Bool)
        case settingsWalletIdCopyClick
        case settingsWalletIdCopied
        case settingsEmailNotifSwitch(value: Bool)
        case settingsPasswordClick
        case settingsTwoFaClick
        case settingsRecoveryPhraseClick
        case settingsChangePinClick
        case settingsBiometryAuthSwitch(value: Bool)
        case settingsLanguageSelected(language: String)
        case settingsPinSelected
        case settingsPasswordSelected
        case settingsCurrencySelected(currency: String)
        case settingsTradingCurrencySelected(currency: String)

        var name: String {
            switch self {
            // Settings - email clicked
            case .settingsEmailClicked:
                return "settings_email_clicked"
            // Settings - phone clicked
            case .settingsPhoneClicked:
                return "settings_phone_clicked"
            // Settings - login to web wallet clicked
            case .settingsWebWalletLoginClick:
                return "settings_web_wallet_login_click"
            // Settings - swap limit clicked
            case .settingsSwapLimitClicked:
                return "settings_swap_limit_clicked"
            case .settingsCloudBackupSwitch:
                return "settings_cloud_backup_switch"
            // Settings - wallet id copy clicked
            case .settingsWalletIdCopyClick:
                return "settings_wallet_id_copy_click"
            // Settings - wallet id copied
            case .settingsWalletIdCopied:
                return "settings_wallet_id_copied"
            // Settings - email notifications switch clicked
            case .settingsEmailNotifSwitch:
                return "settings_email_notif_switch"
            // Settings - change password clicked
            case .settingsPasswordClick:
                return "settings_password_click"
            // Settings - two factor auth clicked
            case .settingsTwoFaClick:
                return "settings_two_fa_click"
            // Settings - recovery phrase clicked
            case .settingsRecoveryPhraseClick:
                return "settings_recovery_phrase_click"
            // Settings - change PIN clicked
            case .settingsChangePinClick:
                return "settings_change_pin_click"
            // Settings - biometry auth switch
            case .settingsBiometryAuthSwitch:
                return "settings_biometry_auth_switch"
            // Settings - change language
            case .settingsLanguageSelected:
                return "settings_language_selected"
            // Settings - PIN changed
            case .settingsPinSelected:
                return "settings_pin_selected"
            // Settings - change password
            case .settingsPasswordSelected:
                return "settings_password_selected"
            // Settings - change currency
            case .settingsCurrencySelected:
                return "settings_currency_selected"
            case .settingsTradingCurrencySelected:
                return "settings_trading_currency_selected"
            }
        }

        var params: [String: String]? {
            nil
        }
    }
}
