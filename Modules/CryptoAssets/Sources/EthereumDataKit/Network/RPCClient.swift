// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import Errors
import EthereumKit
import NetworkKit

protocol LatestBlockClientAPI {
    /// Streams the latest block number.
    func latestBlock(
        network: EVMNetwork
    ) -> AnyPublisher<JsonRpcHexaNumberResponse, NetworkError>
}

final class RPCClient: LatestBlockClientAPI {

    // MARK: - Private Properties

    private let networkAdapter: NetworkAdapterAPI
    private let requestBuilder: RequestBuilder
    private let apiCode: String

    // MARK: - Setup

    init(
        networkAdapter: NetworkAdapterAPI,
        requestBuilder: RequestBuilder,
        apiCode: APICode
    ) {
        self.networkAdapter = networkAdapter
        self.requestBuilder = requestBuilder
        self.apiCode = apiCode
    }

    // MARK: - RPCClient

    func latestBlock(
        network: EVMNetwork
    ) -> AnyPublisher<JsonRpcHexaNumberResponse, NetworkError> {
        createAndPerformHexaNumberRPCRequest(
            network: network,
            encodable: BlockNumberRequest()
        )
    }

    private func createAndPerformHexaNumberRPCRequest(
        network: EVMNetwork,
        encodable: Encodable
    ) -> AnyPublisher<JsonRpcHexaNumberResponse, NetworkError> {
        rpcRequest(network: network, encodable: encodable)
            .publisher
            .flatMap { [networkAdapter] networkRequest in
                networkAdapter.perform(request: networkRequest)
            }
            .eraseToAnyPublisher()
    }

    private func rpcRequest(
        network: EVMNetwork,
        encodable: Encodable
    ) -> Result<NetworkRequest, NetworkError> {
        guard let data = try? encodable.data() else {
            return .failure(NetworkError(request: nil, type: .payloadError(.emptyData)))
        }
        return requestBuilder.post(
            path: network.nodePath,
            body: data
        )
        .flatMap { .success($0) }
        ?? .failure(NetworkError(request: nil, type: .payloadError(.emptyData)))
    }
}

extension EVMNetwork {

    fileprivate var nodePath: String {
        switch self {
        case .avalanceCChain:
            return "/avax/nodes/rpc/ext/bc/C/rpc"
        case .binanceSmartChain:
            return "/bnb/nodes/rpc"
        case .ethereum:
            return "/eth/nodes/rpc"
        case .polygon:
            return "/matic-bor/nodes/rpc"
        }
    }
}
