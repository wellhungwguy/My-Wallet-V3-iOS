import BINDWithdrawDomain
import Combine
import Foundation
import NetworkKit

public typealias BINDWithdrawRepository = BINDWithdrawClient
extension BINDWithdrawRepository: BINDWithdrawRepositoryProtocol {}

public final class BINDWithdrawClient {

    private let requestBuilder: RequestBuilder
    private let network: NetworkAdapterAPI
    private var currency: String = "ARS"

    public init(requestBuilder: RequestBuilder, network: NetworkAdapterAPI) {
        self.requestBuilder = requestBuilder
        self.network = network
    }

    public func currency(_ currency: String) -> Self {
        self.currency = currency
        return self
    }

    public func search(address: String) -> AnyPublisher<BINDBeneficiary, Nabu.Error> {
        let request = requestBuilder.post(
            path: "/payments/bind/beneficiary",
            body: try? ["address": address, "currency": currency].json()
        )!
        return network.perform(request: request)
    }

    public func link(beneficiary beneficiaryId: String) -> AnyPublisher<Void, Nabu.Error> {
        let request = requestBuilder.put(
            path: "/payments/bind/beneficiary",
            body: try? ["beneficiaryId": beneficiaryId].json()
        )!
        return network.perform(request: request)
    }
}
