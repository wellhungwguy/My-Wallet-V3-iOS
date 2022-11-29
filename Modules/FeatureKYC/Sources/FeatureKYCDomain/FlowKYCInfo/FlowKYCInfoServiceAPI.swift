// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

public protocol FlowKYCInfoServiceAPI {

    func isProveFlow() async throws -> Bool?
}
