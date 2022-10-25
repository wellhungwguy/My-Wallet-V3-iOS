// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BigInt
import Combine
import DIKit
import Foundation
import MoneyKit
import NetworkKit

enum GasEstimateError: Error {
    case unableToEstimateGas(NetworkError)
}

protocol GasEstimateServiceAPI {
    func estimateGas(
        network: EVMNetwork,
        transaction: EthereumJsonRpcTransaction
    ) -> AnyPublisher<BigUInt, GasEstimateError>
}

final class GasEstimateService: GasEstimateServiceAPI {

    private let client: EstimateGasClientAPI

    init(client: EstimateGasClientAPI = resolve()) {
        self.client = client
    }

    func estimateGas(
        network: EVMNetwork,
        transaction: EthereumJsonRpcTransaction
    ) -> AnyPublisher<BigUInt, GasEstimateError> {
        client.estimateGas(network: network, transaction: transaction)
            .mapError(GasEstimateError.unableToEstimateGas)
            .map(\.result)
            .map { gasEstimate -> BigInt in
                // Increase the node's gas estimate by 20%.
                gasEstimate + (gasEstimate / 5)
            }
            .map { gasEstimate in
                BigUInt(gasEstimate)
            }
            .eraseToAnyPublisher()
    }
}
