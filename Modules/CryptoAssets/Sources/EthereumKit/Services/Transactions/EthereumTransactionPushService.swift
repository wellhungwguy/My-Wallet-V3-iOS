// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import Errors

enum EthereumTransactionPushError: Error {
    case noTransactionID
    case networkError(NetworkError)
}

protocol EthereumTransactionPushServiceAPI {

    func push(
        transaction: EthereumTransactionEncoded,
        network: EVMNetwork
    ) -> AnyPublisher<String, EthereumTransactionPushError>
}

final class EthereumTransactionPushService: EthereumTransactionPushServiceAPI {

    private let client: TransactionPushClientAPI

    init(client: TransactionPushClientAPI) {
        self.client = client
    }

    func push(
        transaction: EthereumTransactionEncoded,
        network: EVMNetwork
    ) -> AnyPublisher<String, EthereumTransactionPushError> {
        switch network {
        case .ethereum:
            return client.push(transaction: transaction)
                .map(\.txHash)
                .mapError(EthereumTransactionPushError.networkError)
                .eraseToAnyPublisher()
        case .avalanceCChain,
             .binanceSmartChain,
             .polygon:
            return client.evmPush(
                transaction: transaction,
                network: network
            )
            .map(\.txId)
            .mapError(EthereumTransactionPushError.networkError)
            .onNil(EthereumTransactionPushError.noTransactionID)
            .eraseToAnyPublisher()
        }
    }
}
