// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine

public protocol ProveRouterAPI {

    func presentProveFlow(
    ) -> AnyPublisher<VerificationResult, Never>
}
