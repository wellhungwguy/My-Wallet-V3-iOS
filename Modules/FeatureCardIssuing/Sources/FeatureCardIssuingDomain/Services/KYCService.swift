// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import Errors
import Foundation
import PassKit

class KYCService: KYCServiceAPI {

    private let repository: KYCRepositoryAPI

    init(repository: KYCRepositoryAPI) {
        self.repository = repository
    }

    func update(address: Card.Address?, ssn: String?) -> AnyPublisher<KYC, NabuNetworkError> {
        repository.update(address: address, ssn: ssn)
    }

    func fetch() -> AnyPublisher<KYC, NabuNetworkError> {
        repository.fetch()
    }
}
