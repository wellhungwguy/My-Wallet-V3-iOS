// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import EthereumKit
import MoneyKit
import PlatformKit

class EthereumFeeServiceMock: EthereumFeeServiceAPI {
    var underlyingFees: EthereumTransactionFee

    init(underlyingFees: EthereumTransactionFee) {
        self.underlyingFees = underlyingFees
    }

    func fees(
        network: EVMNetwork,
        contractAddress: String?
    ) -> AnyPublisher<EthereumTransactionFee, Never> {
        .just(underlyingFees)
    }
}
