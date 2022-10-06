//  Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import DIKit
import Errors

public struct DomainResolution {
    let currency: String
    let address: String

    public init(currency: String, address: String) {
        self.currency = currency
        self.address = address
    }
}

public struct ReverseResolution {
    let domainName: String

    public init(domainName: String) {
        self.domainName = domainName
    }
}

public protocol BlockchainNameResolutionRepositoryAPI {

    func resolve(
        domainName: String,
        currency: String
    ) -> AnyPublisher<DomainResolution, NetworkError>

    func reverseResolve(
        address: String,
        currency: String
    ) -> AnyPublisher<[ReverseResolution], NetworkError>
}
