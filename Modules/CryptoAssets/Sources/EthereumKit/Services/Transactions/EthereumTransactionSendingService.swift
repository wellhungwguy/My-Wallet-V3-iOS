// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import MoneyKit

public enum EthereumTransactionSendingServiceError: Error {
    case pushTransactionFailed(Error)
    case pushTransactionMalformed(EthereumTransactionPublishedError)
    case signingError(EthereumTransactionSigningServiceError)
}

protocol EthereumTransactionSendingServiceAPI {
    func send(
        transaction: EthereumTransactionEncoded,
        network: EVMNetworkConfig
    ) -> AnyPublisher<EthereumTransactionPublished, EthereumTransactionSendingServiceError>

    func signAndSend(
        transaction: EthereumTransactionCandidate,
        keyPair: EthereumKeyPair,
        network: EVMNetworkConfig
    ) -> AnyPublisher<EthereumTransactionPublished, EthereumTransactionSendingServiceError>
}

final class EthereumTransactionSendingService: EthereumTransactionSendingServiceAPI {

    private let pushService: EthereumTransactionPushServiceAPI
    private let transactionSigner: EthereumTransactionSigningServiceAPI

    init(
        pushService: EthereumTransactionPushServiceAPI,
        transactionSigner: EthereumTransactionSigningServiceAPI
    ) {
        self.pushService = pushService
        self.transactionSigner = transactionSigner
    }

    func signAndSend(
        transaction: EthereumTransactionCandidate,
        keyPair: EthereumKeyPair,
        network: EVMNetworkConfig
    ) -> AnyPublisher<EthereumTransactionPublished, EthereumTransactionSendingServiceError> {
        transactionSigner
            .sign(transaction: transaction, keyPair: keyPair)
            .mapError(EthereumTransactionSendingServiceError.signingError)
            .flatMap { [send] finalised in
                send(finalised, network)
            }
            .eraseToAnyPublisher()
    }

    func send(
        transaction: EthereumTransactionEncoded,
        network: EVMNetworkConfig
    ) -> AnyPublisher<EthereumTransactionPublished, EthereumTransactionSendingServiceError> {
        pushService.push(transaction: transaction, network: network)
            .mapError(EthereumTransactionSendingServiceError.pushTransactionFailed)
            .flatMap { transactionHash in
                EthereumTransactionPublished.create(
                    transaction: transaction,
                    responseHash: transactionHash
                )
                .publisher
                .mapError(EthereumTransactionSendingServiceError.pushTransactionMalformed)
            }
            .eraseToAnyPublisher()
    }
}
