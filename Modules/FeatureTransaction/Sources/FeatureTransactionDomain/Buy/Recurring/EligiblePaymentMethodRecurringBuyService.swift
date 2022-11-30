// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import Errors
import Foundation

final class EligiblePaymentMethodRecurringBuyService: EligiblePaymentMethodRecurringBuyServiceAPI {

    private let repository: EligiblePaymentMethodRecurringBuyRepositoryAPI

    init(repository: EligiblePaymentMethodRecurringBuyRepositoryAPI) {
        self.repository = repository
    }

    // MARK: - EligiblePaymentMethodRecurringBuyServiceAPI

    func fetchEligiblePaymentMethodTypesStartingFromDate(
        _ date: Date?
    ) -> AnyPublisher<[EligibleAndNextPaymentRecurringBuy], NabuNetworkError> {
        repository
            .fetchEligiblePaymentMethodTypesStartingFromDate(date)
    }
}
