// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import EthereumKit
import MoneyKit
import NetworkKit

protocol EVMActivityClientAPI {

    func evmActivity(
        address: String,
        contractAddress: String?,
        network: EVMNetworkConfig
    ) -> AnyPublisher<EVMTransactionHistoryResponse, NetworkError>
}

final class EVMActivityClient: EVMActivityClientAPI {

    // MARK: - Private Properties

    private let apiCode: APICode
    private let networkAdapter: NetworkAdapterAPI
    private let requestBuilder: RequestBuilder

    // MARK: - Setup

    init(
        apiCode: APICode,
        networkAdapter: NetworkAdapterAPI,
        requestBuilder: RequestBuilder
    ) {
        self.apiCode = apiCode
        self.networkAdapter = networkAdapter
        self.requestBuilder = requestBuilder
    }

    func evmActivity(
        address: String,
        contractAddress: String?,
        network: EVMNetworkConfig
    ) -> AnyPublisher<EVMTransactionHistoryResponse, NetworkError> {
        let payload = EVMTransactionHistoryRequest(
            addresses: [address],
            network: network.networkTicker,
            apiCode: apiCode,
            identifier: contractAddress
        )
        let request = requestBuilder.post(
            path: "/currency/evm/txHistory",
            body: try? payload.encode()
        )!
        return networkAdapter.perform(request: request)
    }
}
