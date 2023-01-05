// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine

public protocol ProveRouterAPI {

    func presentFlow(
        proveConfig: ProveConfig
    ) -> PassthroughSubject<VerificationResult, Never>
}
