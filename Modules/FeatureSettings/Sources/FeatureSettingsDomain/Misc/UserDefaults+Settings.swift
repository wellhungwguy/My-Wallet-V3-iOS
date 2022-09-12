// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation
import ToolKit

extension UserDefaults {
    enum Keys: String {
        case didRequestCameraPermissions
        case didRequestMicrophonePermissions
        case didRequestNotificationPermissions
        case encryptedPinPassword
        /// legacyEncryptedPinPassword is required for wallets that created a PIN prior to Homebrew release - see IOS-1537
        case legacyEncryptedPinPassword = "encryptedPINPassword"
        case hasEndedFirstSession
        case pinKey
        case passwordPartHash
        case biometryEnabled
        case cloudBackupEnabled
        case custodySendInterstitialViewed
        case sendToDomainAnnouncementViewed
        case pin
        case password
        case secureChannelDeviceKey
        case secureChannelBrowserIdentities
    }
}
