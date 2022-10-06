// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import DIKit
import Errors

protocol BlockchainNameResolutionClientAPI {

    func resolve(
        domainName: String,
        currency: String
    ) -> AnyPublisher<DomainResolutionResponse, NetworkError>

    func reverseResolve(
        address: String,
        currency: String
    ) -> AnyPublisher<ReverseResolutionResponse, NetworkError>
}
