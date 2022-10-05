// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import FeatureSettingsDomain
import PlatformKit

final class MockKeychainItemWrapping: KeychainItemWrapping {
    var pinValue: String?

    func pin() -> String? {
        pinValue
    }

    var setPinCalled: (pin: String?, called: Bool) = (nil, false)

    func setPin(_ pin: String?) {
        setPinCalled = (pin, true)
    }

    var guidValue: String?

    func guid() -> String? {
        guidValue
    }

    var setGuidCalled: (guid: String?, called: Bool) = (nil, false)

    func setGuid(_ guid: String?) {
        setGuidCalled = (guid, true)
    }

    var sharedKeyValue: String?

    func sharedKey() -> String? {
        sharedKeyValue
    }

    var setSharedKeyCalled: (sharedKey: String?, called: Bool) = (nil, false)

    func setSharedKey(_ sharedKey: String?) {
        setSharedKeyCalled = (sharedKey, true)
    }
}
