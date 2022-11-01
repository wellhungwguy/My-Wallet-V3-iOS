// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import Errors

protocol CancelRecurringBuyClientAPI {
    func cancelRecurringBuyWithId(_ id: String) -> AnyPublisher<Void, NabuNetworkError>
}
