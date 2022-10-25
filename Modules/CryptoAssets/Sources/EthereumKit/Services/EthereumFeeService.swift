// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import DIKit
import MoneyKit

/// Service that provides fees to transact EVM tokens.
public protocol EthereumFeeServiceAPI {
    /// Streams a single `EthereumTransactionFee`, representing suggested fee amounts based on mempool.
    /// Never fails, uses default Fee values if network call fails.
    /// - Parameter cryptoCurrency: An EVM Native token or ERC20 token.
    func fees(network: EVMNetwork, contractAddress: String?) -> AnyPublisher<EthereumTransactionFee, Never>
}

extension EthereumFeeServiceAPI {

    public func fees(network: EVMNetwork) -> AnyPublisher<EthereumTransactionFee, Never> {
        fees(network: network, contractAddress: nil)
    }

    public func fees(network: EVMNetwork, cryptoCurrency: CryptoCurrency) -> AnyPublisher<EthereumTransactionFee, Never> {
        fees(network: network, contractAddress: cryptoCurrency.assetModel.kind.erc20ContractAddress)
    }
}

final class EthereumFeeService: EthereumFeeServiceAPI {

    // MARK: - CryptoFeeServiceAPI

    func fees(network: EVMNetwork, contractAddress: String?) -> AnyPublisher<EthereumTransactionFee, Never> {
        switch network.networkConfig.networkTicker {
        case _EVMNetwork.polygon.rawValue, _EVMNetwork.ethereum.rawValue:
            return client
                .fees(
                    network: network.networkConfig,
                    contractAddress: contractAddress
                )
                .map { EthereumTransactionFee(response: $0, network: network) }
                .replaceError(with: EthereumTransactionFee.default(network: network))
                .eraseToAnyPublisher()
        default:
            return client
                .newFees(
                    network: network.networkConfig,
                    contractAddress: contractAddress
                )
                .map { EthereumTransactionFee(response: $0, network: network) }
                .replaceError(with: EthereumTransactionFee.default(network: network))
                .eraseToAnyPublisher()
        }
    }

    // MARK: - Private Properties

    private let client: TransactionFeeClientAPI

    // MARK: - Init

    init(client: TransactionFeeClientAPI = resolve()) {
        self.client = client
    }
}

extension EthereumTransactionFee {

    fileprivate init(response: NewTransactionFeeResponse, network: EVMNetwork) {
        self.init(
            regularMinor: response.normal,
            priorityMinor: response.high,
            gasLimit: response.gasLimit,
            gasLimitContract: response.gasLimitContract,
            network: network
        )
    }

    fileprivate init(response: TransactionFeeResponse, network: EVMNetwork) {
        self.init(
            regularGwei: response.regular,
            priorityGwei: response.priority,
            gasLimit: response.gasLimit,
            gasLimitContract: response.gasLimitContract,
            network: network
        )
    }
}
