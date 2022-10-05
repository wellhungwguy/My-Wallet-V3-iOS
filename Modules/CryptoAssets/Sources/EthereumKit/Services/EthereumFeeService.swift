// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import DIKit
import MoneyKit

/// Service that provides fees to transact EVM tokens.
public protocol EthereumFeeServiceAPI {
    /// Streams a single `EthereumTransactionFee`, representing suggested fee amounts based on mempool.
    /// Never fails, uses default Fee values if network call fails.
    /// - Parameter cryptoCurrency: An EVM Native token or ERC20 token.
    func fees(cryptoCurrency: CryptoCurrency) -> AnyPublisher<EthereumTransactionFee, Never>
}

final class EthereumFeeService: EthereumFeeServiceAPI {

    // MARK: - CryptoFeeServiceAPI

    func fees(cryptoCurrency: CryptoCurrency) -> AnyPublisher<EthereumTransactionFee, Never> {
        guard let network = cryptoCurrency.assetModel.evmNetwork else {
            let code = cryptoCurrency.code
            let chain = cryptoCurrency.assetModel.kind.erc20ParentChain?.rawValue ?? ""
            fatalError("Incompatible Asset: '\(code)', chain: '\(chain)'.")
        }
        let contractAddress = cryptoCurrency.assetModel.kind.erc20ContractAddress
        switch network {
        case .avalanceCChain,
             .binanceSmartChain:
            return client
                .newFees(
                    network: network,
                    contractAddress: contractAddress
                )
                .map { EthereumTransactionFee(response: $0, network: network) }
                .replaceError(with: EthereumTransactionFee.default(network: network))
                .eraseToAnyPublisher()
        case .ethereum,
             .polygon:
            return client
                .fees(
                    network: network,
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
