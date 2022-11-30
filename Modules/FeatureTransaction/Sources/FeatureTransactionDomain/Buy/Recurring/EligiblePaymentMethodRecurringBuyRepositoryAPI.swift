// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import Errors
import Foundation

public protocol EligiblePaymentMethodRecurringBuyRepositoryAPI {
    func fetchEligiblePaymentMethodTypesStartingFromDate(
        _ date: Date?
    ) -> AnyPublisher<[EligibleAndNextPaymentRecurringBuy], NabuNetworkError>
}
