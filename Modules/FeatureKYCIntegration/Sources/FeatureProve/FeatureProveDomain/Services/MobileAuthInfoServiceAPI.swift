// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

public protocol MobileAuthInfoServiceAPI {

    func getMobileAuthInfo() async throws -> MobileAuthInfo?
}
