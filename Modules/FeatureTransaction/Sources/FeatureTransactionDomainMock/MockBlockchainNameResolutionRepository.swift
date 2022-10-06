// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import Errors
import FeatureTransactionDomain

final class MockBlockchainNameResolutionRepository: BlockchainNameResolutionRepositoryAPI {

    var underlyingResolve: (
        _ domainName: String,
        _ currency: String
    ) -> AnyPublisher<DomainResolution, NetworkError> = { _, currency in
        .just(.init(currency: currency, address: "address"))
    }

    var underlyingReverseResolve: (
        _ address: String,
        _ currency: String
    ) -> AnyPublisher<[ReverseResolution], NetworkError> = { _, _ in
        .just([.init(domainName: "domainName")])
    }

    func resolve(
        domainName: String,
        currency: String
    ) -> AnyPublisher<DomainResolution, NetworkError> {
        underlyingResolve(domainName, currency)
    }

    func reverseResolve(
        address: String,
        currency: String
    ) -> AnyPublisher<[ReverseResolution], NetworkError> {
        underlyingReverseResolve(address, currency)
    }
}
