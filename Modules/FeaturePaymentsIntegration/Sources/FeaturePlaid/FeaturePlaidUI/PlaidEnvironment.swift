// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainNamespace
import ComposableArchitecture
import FeaturePlaidDomain
import Foundation

public struct PlaidEnvironment {
    public let app: AppProtocol
    public let mainQueue: AnySchedulerOf<DispatchQueue>
    public let plaidRepository: PlaidRepositoryAPI
    public let dismissFlow: (Bool) -> Void

    public init(
        app: AppProtocol,
        mainQueue: AnySchedulerOf<DispatchQueue>,
        plaidRepository: PlaidRepositoryAPI,
        dismissFlow: @escaping (Bool) -> Void
    ) {
        self.app = app
        self.mainQueue = mainQueue
        self.plaidRepository = plaidRepository
        self.dismissFlow = dismissFlow
    }
}
