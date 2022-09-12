// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit
import FeatureKYCDomain
import MoneyKit
import PlatformKit
import class PlatformUIKit.AnnouncementRecorder
import RxRelay
import RxSwift
import ToolKit

public protocol KeychainItemWrapping: AnyObject {
    func pin() -> String?
    func setPin(_ pin: String?)

    func guid() -> String?
    func setGuid(_ guid: String?)

    func sharedKey() -> String?
    func setSharedKey(_ sharedKey: String?)
}

public protocol AppSettingsBaseAPI: AnyObject {
    func reset()
}

public typealias BlockchainSettingsAppAPI = AppSettingsAuthenticating
    & AppSettingsSecureChannel
    & CloudBackupConfiguring
    & PermissionSettingsAPI
    & AppSettingsBaseAPI

/**
 Settings for the current user.
 All settings are written and read from NSUserDefaults.
 */
@objc
public final class BlockchainSettings: NSObject {

    // MARK: - App

    @objc(BlockchainSettingsApp)
    public final class App: NSObject, BlockchainSettingsAppAPI {

        @Inject @objc public static var shared: App

        @LazyInject private var defaults: CacheSuite

        // MARK: - Properties

        public var didRequestCameraPermissions: Bool {
            get {
                defaults.bool(forKey: UserDefaults.Keys.didRequestCameraPermissions.rawValue)
            }
            set {
                defaults.set(newValue, forKey: UserDefaults.Keys.didRequestCameraPermissions.rawValue)
            }
        }

        public var didRequestMicrophonePermissions: Bool {
            get {
                defaults.bool(forKey: UserDefaults.Keys.didRequestMicrophonePermissions.rawValue)
            }
            set {
                defaults.set(newValue, forKey: UserDefaults.Keys.didRequestMicrophonePermissions.rawValue)
            }
        }

        public var didRequestNotificationPermissions: Bool {
            get {
                defaults.bool(forKey: UserDefaults.Keys.didRequestNotificationPermissions.rawValue)
            }
            set {
                defaults.set(newValue, forKey: UserDefaults.Keys.didRequestNotificationPermissions.rawValue)
            }
        }

        /**
         Stores the encrypted wallet password.

         - Note:
         The value of this setting is the result of calling the `encrypt(_ data: String, password: String)` function of the wallet.

         - Important:
         The encryption key is generated from the pin created by the user.
         legacyEncryptedPinPassword is required for wallets that created a PIN prior to Homebrew release - see IOS-1537
         */
        public var encryptedPinPassword: String? {
            atomicGet(on: readWriteQueue) {
                let encryptedPinPassword = defaults.string(
                    forKey: UserDefaults.Keys.encryptedPinPassword.rawValue
                )
                let legacyEncryptedPinPassword = defaults.string(
                    forKey: UserDefaults.Keys.legacyEncryptedPinPassword.rawValue
                )
                return encryptedPinPassword ?? legacyEncryptedPinPassword
            }
        }

        public func set(encryptedPinPassword: String?) {
            atomicSet(value: encryptedPinPassword, on: readWriteQueue) { encryptedPinPasswordValue in
                defaults.set(
                    encryptedPinPasswordValue,
                    forKey: UserDefaults.Keys.encryptedPinPassword.rawValue
                )
                defaults.set(
                    nil,
                    forKey: UserDefaults.Keys.legacyEncryptedPinPassword.rawValue
                )
            }
        }

        public var hasEndedFirstSession: Bool {
            get {
                defaults.bool(forKey: UserDefaults.Keys.hasEndedFirstSession.rawValue)
            }
            set {
                defaults.set(newValue, forKey: UserDefaults.Keys.hasEndedFirstSession.rawValue)
            }
        }

        public var pin: String? {
            atomicGet(on: readWriteQueue) { [keychainItemWrapper] in
                keychainItemWrapper.pin()
            }
        }

        public func set(pin: String?) {
            atomicSet(value: pin, on: readWriteQueue) { [keychainItemWrapper] pinValue in
                keychainItemWrapper.setPin(pinValue)
            }
        }

        public var pinKey: String? {
            atomicGet(on: readWriteQueue) {
                defaults.string(forKey: UserDefaults.Keys.pinKey.rawValue)
            }
        }

        public func set(pinKey: String?) {
            atomicSet(value: pinKey, on: readWriteQueue) { pinKeyValue in
                defaults.set(pinKeyValue, forKey: UserDefaults.Keys.pinKey.rawValue)
            }
        }

        /// The first 5 characters of SHA256 hash of the user's password
        public var passwordPartHash: String? {
            atomicGet(on: readWriteQueue) {
                defaults.string(forKey: UserDefaults.Keys.passwordPartHash.rawValue)
            }
        }

        public func set(passwordPartHash: String?) {
            atomicSet(value: passwordPartHash, on: readWriteQueue) { passwordPartHashValue in
                defaults.set(passwordPartHashValue, forKey: UserDefaults.Keys.passwordPartHash.rawValue)
            }
        }

        /**
         Keeps track if the user has elected to use biometric authentication in the application.

         - Note:
         This setting should be **deprecated** in the future, as we should always assume a user
         wants to use this feature if it is enabled system-wide.

         - SeeAlso:
         [Human Interface Guidelines](https://developer.apple.com/design/human-interface-guidelines/ios/user-interaction/authentication)
         */
        public var biometryEnabled: Bool {
            atomicGet(on: readWriteQueue) {
                defaults.bool(forKey: UserDefaults.Keys.biometryEnabled.rawValue)
            }
        }

        public func set(biometryEnabled: Bool) {
            atomicSet(value: biometryEnabled, on: readWriteQueue) { biometryEnabledValue in
                defaults.set(
                    biometryEnabledValue,
                    forKey: UserDefaults.Keys.biometryEnabled.rawValue
                )
            }
        }

        /**
         Determines if the application should back up credentials to iCloud.

         - Note:
         The value of this setting is controlled by a switch on the settings screen.

         The default of this setting is `true`.
         */
        public var cloudBackupEnabled: Bool {
            get {
                defaults.bool(forKey: UserDefaults.Keys.cloudBackupEnabled.rawValue)
            }
            set {
                defaults.set(newValue, forKey: UserDefaults.Keys.cloudBackupEnabled.rawValue)
            }
        }

        public var deviceKey: String? {
            get {
                defaults.string(forKey: UserDefaults.Keys.secureChannelDeviceKey.rawValue)
            }
            set {
                defaults.set(newValue, forKey: UserDefaults.Keys.secureChannelDeviceKey.rawValue)
            }
        }

        public var browserIdentities: String? {
            get {
                defaults.string(forKey: UserDefaults.Keys.secureChannelBrowserIdentities.rawValue)
            }
            set {
                defaults.set(newValue, forKey: UserDefaults.Keys.secureChannelBrowserIdentities.rawValue)
            }
        }

        public var custodySendInterstitialViewed: Bool {
            get {
                defaults.bool(forKey: UserDefaults.Keys.custodySendInterstitialViewed.rawValue)
            }
            set {
                defaults.set(newValue, forKey: UserDefaults.Keys.custodySendInterstitialViewed.rawValue)
            }
        }

        public var sendToDomainAnnouncementViewed: Bool {
            get {
                defaults.bool(forKey: UserDefaults.Keys.sendToDomainAnnouncementViewed.rawValue)
            }
            set {
                defaults.set(newValue, forKey: UserDefaults.Keys.sendToDomainAnnouncementViewed.rawValue)
            }
        }

        private var buySellCache: EventCache {
            resolve()
        }

        private var fiatSettings: FiatCurrencySettingsServiceAPI {
            resolve()
        }

        private let enabledCurrenciesService: EnabledCurrenciesServiceAPI
        private let keychainItemWrapper: KeychainItemWrapping

        private let readWriteQueue = DispatchQueue(label: "Atomic read/write queue", attributes: .concurrent)

        public init(
            enabledCurrenciesService: EnabledCurrenciesServiceAPI = resolve(),
            keychainItemWrapper: KeychainItemWrapping = resolve()
        ) {
            self.enabledCurrenciesService = enabledCurrenciesService
            self.keychainItemWrapper = keychainItemWrapper

            super.init()

            defaults.register(defaults: [
                UserDefaults.Keys.cloudBackupEnabled.rawValue: true
            ])
        }

        // MARK: - Public

        /**
         Resets app-specific settings back to their initial value.
         - Note:
         This function will not reset any settings which are derived from wallet options.
         */
        public func reset() {
            clearPin()
            sendToDomainAnnouncementViewed = false
            custodySendInterstitialViewed = false

            let kycSettings: KYCSettingsAPI = resolve()
            kycSettings.reset()
            AnnouncementRecorder.reset()

            buySellCache.reset()

            Logger.shared.info("Application settings have been reset.")
        }

        /// - Warning: Calling This function will remove **ALL** settings in the application.
        /// Resets secure keys from
        public func clear() {
            let secureKeys: [UserDefaults.Keys] = [
                .passwordPartHash,
                .pinKey,
                .encryptedPinPassword,
                .legacyEncryptedPinPassword,
                .secureChannelDeviceKey,
                .secureChannelBrowserIdentities
            ]
            for key in secureKeys {
                defaults.removeObject(forKey: key.rawValue)
            }
            Logger.shared.info("Application settings have been cleared.")
        }

        public func clearPin() {
            set(pin: nil)
            set(encryptedPinPassword: nil)
            set(pinKey: nil)
            set(passwordPartHash: nil)
        }
    }
}

private func atomicGet<Value>(
    on queue: DispatchQueue,
    read: () -> Value
) -> Value {
    queue.sync {
        read()
    }
}

private func atomicSet<Value>(
    value: Value,
    on queue: DispatchQueue,
    write: (Value) -> Void
) {
    queue.sync(flags: .barrier) {
        write(value)
    }
}
