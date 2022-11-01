// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import Errors

final class CancelRecurringBuyService: CancelRecurringBuyServiceAPI {

    private let repository: CancelRecurringBuyRepositoryAPI

    init(repository: CancelRecurringBuyRepositoryAPI) {
        self.repository = repository
    }

    func cancelRecurringBuyWithId(_ id: String) -> AnyPublisher<Void, NabuNetworkError> {
        repository.cancelRecurringBuyWithId(id)
    }
}
