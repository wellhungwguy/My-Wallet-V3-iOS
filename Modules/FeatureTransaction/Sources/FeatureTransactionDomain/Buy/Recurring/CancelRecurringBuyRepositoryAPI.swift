// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import Errors

public protocol CancelRecurringBuyRepositoryAPI {
    func cancelRecurringBuyWithId(_ id: String) -> AnyPublisher<Void, NabuNetworkError>
}
