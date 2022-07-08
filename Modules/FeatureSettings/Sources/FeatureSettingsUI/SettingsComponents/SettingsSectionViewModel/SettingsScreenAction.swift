// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import FeatureCardPaymentDomain
import FeatureReferralDomain
import MoneyKit
import PlatformKit

/// This enum aggregates possible action types that can be done in the dashboard
public enum SettingsScreenAction {
    case launchChangePassword
    case launchWebLogin
    case promptGuidCopy
    case presentTradeLimits
    case launchPIT
    case logout
    case showAppStore
    case showBackupScreen
    case showChangePinScreen
    case showCurrencySelectionScreen
    case showTradingCurrencySelectionScreen
    case showUpdateEmailScreen
    case showUpdateMobileScreen
    case showURL(URL)
    case showRemoveCardScreen(CardData)
    case showRemoveBankScreen(Beneficiary)
    case showAddCardScreen
    case showAddBankScreen(FiatCurrency)
    case showAccountsAndAddresses
    case showContactSupport
    case showWebLogin
    case showCardIssuing
    case showNotificationsSettings
    case showReferralScreen(Referral)
    case showUserDeletionScreen
    case none
}
