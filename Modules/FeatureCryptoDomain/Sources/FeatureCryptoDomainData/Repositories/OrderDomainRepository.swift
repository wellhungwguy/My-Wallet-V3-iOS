// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import FeatureCryptoDomainDomain
import Foundation

public final class OrderDomainRepository: OrderDomainRepositoryAPI {

    // MARK: - Properties

    private let apiClient: OrderDomainClientAPI

    // MARK: - Setup

    public init(apiClient: OrderDomainClientAPI) {
        self.apiClient = apiClient
    }

    public func createDomainOrder(
        isFree: Bool,
        domainName: String,
        resolutionRecords: [ResolutionRecord]?
    ) -> AnyPublisher<OrderDomainResult, OrderDomainRepositoryError> {
        apiClient
            .postOrder(
                payload: PostOrderRequest(
                    domainCampaign: Constants.udDomainCampaign.rawValue,
                    domain: domainName,
                    owner: resolutionRecords?.first?.walletAddress ?? "",
                    records: resolutionRecords?.map(Record.init) ?? [],
                    isFree: isFree
                )
            )
            .map(OrderDomainResult.init(response:))
            .mapError(OrderDomainRepositoryError.networkError)
            .eraseToAnyPublisher()
    }
}

extension OrderDomainResult {
    init(response: PostOrderResponse) {
        let isFree: Bool = response.isFree
        let orderNumber: Int = response.order?.orderNumber.flatMap(Int.init) ?? 0
        let redirectUrl: String = response.redirectUrl ?? ""
        self.init(
            domainType: isFree ? .free : .premium,
            orderNumber: isFree ? orderNumber : nil,
            redirectUrl: isFree ? nil : redirectUrl
        )
    }
}
