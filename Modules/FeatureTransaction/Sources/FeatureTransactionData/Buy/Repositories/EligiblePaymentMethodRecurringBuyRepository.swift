// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import Errors
import FeatureTransactionDomain
import Foundation

final class EligiblePaymentMethodRecurringBuyRepository: EligiblePaymentMethodRecurringBuyRepositoryAPI {

    private let client: EligiblePaymentMethodRecurringBuyClientAPI

    init(client: EligiblePaymentMethodRecurringBuyClientAPI) {
        self.client = client
    }

    // MARK: - EligiblePaymentMethodRecurringBuyRepositoryAPI

    func fetchEligiblePaymentMethodTypesStartingFromDate(
        _ date: Date?
    ) -> AnyPublisher<[EligibleAndNextPaymentRecurringBuy], NabuNetworkError> {
        client
            .fetchEligiblePaymentMethodTypesStartingFromDate(date)
            .map(\.nextPayments)
            .map { $0.compactMap(EligibleAndNextPaymentRecurringBuy.init(response:)) }
            .eraseToAnyPublisher()
    }
}
