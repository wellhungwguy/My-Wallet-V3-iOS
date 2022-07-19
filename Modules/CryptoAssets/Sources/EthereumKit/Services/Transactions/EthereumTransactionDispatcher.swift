// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BigInt
import Combine
import FeatureTransactionDomain
import PlatformKit

public typealias RecordLastTransaction =
    (EthereumTransactionPublished) -> AnyPublisher<EthereumTransactionPublished, Never>

public protocol EthereumTransactionDispatcherAPI {

    func send(
        transaction: EthereumTransactionCandidate,
        secondPassword: String,
        network: EVMNetwork
    ) -> AnyPublisher<EthereumTransactionPublished, Error>
}

final class EthereumTransactionDispatcher: EthereumTransactionDispatcherAPI {

    private let recordLastTransaction: RecordLastTransaction
    private let keyPairProvider: AnyKeyPairProvider<EthereumKeyPair>
    private let transactionSendingService: EthereumTransactionSendingServiceAPI

    init(
        keyPairProvider: AnyKeyPairProvider<EthereumKeyPair>,
        transactionSendingService: EthereumTransactionSendingServiceAPI,
        recordLastTransaction: @escaping RecordLastTransaction
    ) {
        self.keyPairProvider = keyPairProvider
        self.transactionSendingService = transactionSendingService
        self.recordLastTransaction = recordLastTransaction
    }

    func send(
        transaction: EthereumTransactionCandidate,
        secondPassword: String,
        network: EVMNetwork
    ) -> AnyPublisher<EthereumTransactionPublished, Error> {
        keyPairProvider.keyPair(with: secondPassword)
            .asPublisher()
            .flatMap { [transactionSendingService] keyPair
                -> AnyPublisher<EthereumTransactionPublished, Error> in
                transactionSendingService.signAndSend(
                    transaction: transaction,
                    keyPair: keyPair,
                    network: network
                )
                .eraseError()
            }
            .flatMap { [recordLastTransaction] transaction
                -> AnyPublisher<EthereumTransactionPublished, Error> in
                if network == .ethereum {
                    return recordLastTransaction(transaction)
                        .setFailureType(to: Error.self)
                        .eraseToAnyPublisher()
                } else {
                    return .just(transaction)
                }
            }
            .eraseToAnyPublisher()
    }
}
