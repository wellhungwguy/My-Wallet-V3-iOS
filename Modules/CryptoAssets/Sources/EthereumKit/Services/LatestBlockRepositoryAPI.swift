// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BigInt
import Combine
import Errors
import MoneyKit

public protocol LatestBlockRepositoryAPI {
    func latestBlock(
        network: EVMNetworkConfig
    ) -> AnyPublisher<BigInt, NetworkError>
}
