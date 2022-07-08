// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation
import MoneyKit
import WalletPayloadKit

public struct WalletSettings: Equatable {

    public enum Feature: String {
        case segwit
    }

    private let userDefaults: UserDefaults
    private let rawDisplayCurrency: String

    public let countryCode: String
    public let language: String
    public let email: String
    public let smsNumber: String?
    public let isSMSVerified: Bool
    public let isEmailNotificationsEnabled: Bool
    public let isEmailVerified: Bool
    public let authenticator: WalletAuthenticatorType
    public let features: [Feature: Bool]

    public var displayCurrency: FiatCurrency? {
        FiatCurrency(rawValue: rawDisplayCurrency)
    }

    init(response: SettingsResponse, userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
        rawDisplayCurrency = response.currency
        countryCode = response.countryCode
        language = response.language
        email = response.email
        smsNumber = response.smsNumber
        isSMSVerified = response.smsVerified
        isEmailVerified = response.emailVerified
        isEmailNotificationsEnabled = response.emailNotificationsEnabled
        authenticator = WalletAuthenticatorType(rawValue: response.authenticator) ?? .standard
        features = response.invited.reduce(into: [Feature: Bool]()) { result, data in
            guard let key = Feature(rawValue: data.key.rawValue) else {
                return
            }
            result[key] = data.value
        }
    }
}
