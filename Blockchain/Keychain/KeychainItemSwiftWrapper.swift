// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import FeatureSettingsDomain
import Foundation

final class KeychainItemSwiftWrapper: KeychainItemWrapping {

    func pin() -> String? {
        KeychainItemWrapper.pin()
    }

    func setPin(_ pin: String?) {
        KeychainItemWrapper.setPinInKeychain(pin)
    }

    func guid() -> String? {
        KeychainItemWrapper.guid()
    }

    func setGuid(_ guid: String?) {
        KeychainItemWrapper.setGuidInKeychain(guid)
    }

    func sharedKey() -> String? {
        KeychainItemWrapper.sharedKey()
    }

    func setSharedKey(_ sharedKey: String?) {
        KeychainItemWrapper.setSharedKeyInKeychain(sharedKey)
    }
}
