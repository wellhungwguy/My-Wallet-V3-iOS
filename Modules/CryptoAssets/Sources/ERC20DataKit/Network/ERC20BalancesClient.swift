// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import EthereumKit
import MoneyKit
import NetworkKit

/// A client in charge of interacting with the ethereum backend service, in order to fetch ERC-20 data.
///
/// - Note: The `New` suffix should be removed after `ERC20DataKit` data layer migration has been completed.
protocol ERC20BalancesClientAPI {

    /// Fetches the ERC-20 token accounts associated with the given ethereum account address, on the given network.
    ///
    /// - Parameter address: The ethereum account address to fetch the ERC-20 token accounts for.
    /// - Parameter network: The EVMNetwork.
    ///
    /// - Returns: A publisher that emits a `ERC20TokenAccountsResponse` on success, or a `NetworkError` on failure.
    func evmTokensBalances(for address: String, network: EVMNetworkConfig) -> AnyPublisher<EVMBalancesResponse, NetworkError>

    /// Fetches the ERC-20 token accounts associated with the given ethereum account address.
    ///
    /// - Parameter address: The ethereum account address to fetch the ERC-20 token accounts for.
    ///
    /// - Returns: A publisher that emits a `ERC20TokenAccountsReponse` on success, or a `NetworkError` on failure.
    func ethereumTokensBalances(for address: String) -> AnyPublisher<ERC20TokenAccountsResponse, NetworkError>
}

/// The client in charge of interacting with the ethereum backend service, in order to fetch ERC-20 data.
final class ERC20BalancesClient: ERC20BalancesClientAPI {

    // MARK: - Private Types

    private enum Endpoint {

        /// URL path to the `tokens` endpoint.
        static func ethereumTokens(for address: String) -> String {
            "/eth/v2/account/\(address)/tokens"
        }

        /// URL path to the `tokens` endpoint.
        static var evmBalances: String {
            "/currency/evm/balance"
        }
    }

    // MARK: - Private Properties

    private let apiCode: APICode
    private let networkAdapter: NetworkAdapterAPI
    private let requestBuilder: RequestBuilder

    // MARK: - Setup

    /// Creates an ERC-20 account client.
    ///
    /// - Parameters:
    ///   - networkAdapter: A network adapter.
    ///   - requestBuilder: A request builder.
    init(
        apiCode: APICode,
        networkAdapter: NetworkAdapterAPI,
        requestBuilder: RequestBuilder
    ) {
        self.apiCode = apiCode
        self.networkAdapter = networkAdapter
        self.requestBuilder = requestBuilder
    }

    // MARK: - Internal Methods

    func evmTokensBalances(
        for address: String,
        network: EVMNetworkConfig
    ) -> AnyPublisher<EVMBalancesResponse, NetworkError> {
        let payload = EVMBalancesRequest(
            addresses: [address],
            network: network.networkTicker,
            apiCode: apiCode
        )
        let request = requestBuilder.post(
            path: Endpoint.evmBalances,
            body: try? payload.encode()
        )!
        return networkAdapter.perform(request: request)
    }

    func ethereumTokensBalances(
        for address: String
    ) -> AnyPublisher<ERC20TokenAccountsResponse, NetworkError> {
        let request = requestBuilder.get(
            path: Endpoint.ethereumTokens(for: address)
        )!
        return networkAdapter.perform(request: request)
    }
}
