// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import Errors
import FeatureCardIssuingDomain
import Foundation

public final class KYCRepository: KYCRepositoryAPI {

    private let client: KYCClientAPI

    public init(client: KYCClientAPI) {
        self.client = client
    }

    public func update(address: Card.Address?, ssn: String?) -> AnyPublisher<KYC, NabuNetworkError> {
        client.update(.init(ssn: ssn, address: address))
    }

    public func fetch() -> AnyPublisher<KYC, NabuNetworkError> {
        client.fetch()
    }
}
