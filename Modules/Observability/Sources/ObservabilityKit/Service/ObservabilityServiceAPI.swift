// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

public protocol ObservabilityServiceAPI: AnyObject {

    func start(with appKey: String)
    func addSessionProperty(_ value: String, withKey key: String, permanent: Bool) -> Bool
}
