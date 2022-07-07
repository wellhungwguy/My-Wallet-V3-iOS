import Combine
import BINDWithdrawDomain
import Foundation
import NetworkKit

public typealias BINDWithdrawRepository = BINDWithdrawClient
extension BINDWithdrawRepository: BINDWithdrawRepositoryProtocol { }

public final class BINDWithdrawClient {

    private let requestBuilder: RequestBuilder
    private let network: NetworkAdapterAPI

    init(requestBuilder: RequestBuilder, network: NetworkAdapterAPI) {
        self.requestBuilder = requestBuilder
        self.network = network
    }

    public func search(_ address: String) -> AnyPublisher<BIND, Nabu.Error> {
        let request = requestBuilder.get(
            path: "/payments/bind",
            parameters: [URLQueryItem(name: "cbuAlias", value: address)]
        )!
        return network.perform(request: request)
    }

    public func link(_ address: String) -> AnyPublisher<Void, Nabu.Error> {
        let request = requestBuilder.post(
            path: "/payments/bind",
            body: try? ["address": address].json()
        )!
        return network.perform(request: request)
    }
}
