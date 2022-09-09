// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import Errors
import Foundation

final class LegalService: LegalServiceAPI {

    private let repository: LegalRepositoryAPI

    init(
        repository: LegalRepositoryAPI
    ) {
        self.repository = repository
    }

    func fetchLegalItems() -> AnyPublisher<[LegalItem], NabuNetworkError> {
        repository.fetchLegalItems()
    }

    func setAccepted(legalItems: [LegalItem]) -> AnyPublisher<[LegalItem], NabuNetworkError> {
        repository.setAccepted(legalItems: legalItems)
    }
}
