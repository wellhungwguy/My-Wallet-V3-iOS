// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import Errors
import FeatureTransactionDomain

final class CancelRecurringBuyRepository: CancelRecurringBuyRepositoryAPI {

    private let client: CancelRecurringBuyClientAPI

    init(client: CancelRecurringBuyClientAPI) {
        self.client = client
    }

    // MARK: - CancelRecurringBuyRepositoryAPI

    func cancelRecurringBuyWithId(_ id: String) -> AnyPublisher<Void, NabuNetworkError> {
        client.cancelRecurringBuyWithId(id)
    }
}
