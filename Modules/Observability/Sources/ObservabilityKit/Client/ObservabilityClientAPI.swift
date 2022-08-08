// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

public protocol ObservabilityClientAPI: AnyObject {

    func start(withKey: String)
    func addSessionProperty(_ value: String, withKey key: String, permanent: Bool) -> Bool
}
