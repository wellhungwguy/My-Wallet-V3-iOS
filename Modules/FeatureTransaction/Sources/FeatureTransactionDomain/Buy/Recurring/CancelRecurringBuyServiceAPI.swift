// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import Errors

protocol CancelRecurringBuyServiceAPI {
    func cancelRecurringBuyWithId(_ id: String) -> AnyPublisher<Void, NabuNetworkError>
}
