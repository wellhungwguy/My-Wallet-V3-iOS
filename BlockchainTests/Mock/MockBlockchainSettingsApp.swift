// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import FeatureSettingsDomain
import Foundation
import PlatformKit

final class MockBlockchainSettingsApp: BlockchainSettingsAppAPI {
    internal init(
        biometryEnabled: Bool = false,
        browserIdentities: String? = nil,
        cloudBackupEnabled: Bool = true,
        deviceKey: String? = nil,
        didRequestCameraPermissions: Bool = false,
        didRequestMicrophonePermissions: Bool = false,
        didRequestNotificationPermissions: Bool = false,
        encryptedPinPassword: String? = nil,
        isPinSet: Bool = false,
        passwordPartHash: String? = nil,
        pin: String? = nil,
        pinKey: String? = nil,
        clearCalled: Bool = false,
        clearPinCalled: Bool = false,
        resetCalled: Bool = false
    ) {
        self.biometryEnabled = biometryEnabled
        self.browserIdentities = browserIdentities
        self.cloudBackupEnabled = cloudBackupEnabled
        self.deviceKey = deviceKey
        self.didRequestCameraPermissions = didRequestCameraPermissions
        self.didRequestMicrophonePermissions = didRequestMicrophonePermissions
        self.didRequestNotificationPermissions = didRequestNotificationPermissions
        self.encryptedPinPassword = encryptedPinPassword
        self.isPinSet = isPinSet
        self.passwordPartHash = passwordPartHash
        self.pin = pin
        self.pinKey = pinKey
        self.clearCalled = clearCalled
        self.clearPinCalled = clearPinCalled
        self.resetCalled = resetCalled
    }

    // MARK: BlockchainSettingsAppAPI

    private(set) var biometryEnabled: Bool = false
    func set(biometryEnabled: Bool) {
        self.biometryEnabled = biometryEnabled
    }

    var browserIdentities: String?
    var cloudBackupEnabled: Bool = true
    var deviceKey: String?
    var didRequestCameraPermissions: Bool = false
    var didRequestMicrophonePermissions: Bool = false
    var didRequestNotificationPermissions: Bool = false

    private(set) var encryptedPinPassword: String?
    func set(encryptedPinPassword: String?) {
        self.encryptedPinPassword = encryptedPinPassword
    }

    var isPinSet: Bool = false

    private(set) var passwordPartHash: String?
    func set(passwordPartHash: String?) {
        self.passwordPartHash = passwordPartHash
    }

    private(set) var pin: String?
    func set(pin: String?) {
        self.pin = pin
    }

    private(set) var pinKey: String?
    func set(pinKey: String?) {
        self.pinKey = pinKey
    }

    func clear() {
        clearCalled = true
    }

    func clearPin() {
        clearPinCalled = true
    }

    func reset() {
        resetCalled = true
    }

    // MARK: Mock Supporting

    var clearCalled: Bool = false
    var clearPinCalled: Bool = false
    var resetCalled: Bool = false
}
