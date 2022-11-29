// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import Errors
import FeatureTransactionDomain
import MoneyKit
import PlatformKit

final class RecurringBuyProviderRepository: RecurringBuyProviderRepositoryAPI {

    private let client: RecurringBuyProviderClientAPI

    init(client: RecurringBuyProviderClientAPI) {
        self.client = client
    }

    func fetchRecurringBuysForCryptoCurrency(
        _ cryptoCurrency: CryptoCurrency
    ) -> AnyPublisher<[RecurringBuy], NabuNetworkError> {
        client
            .fetchRecurringBuysForCryptoCurrency(cryptoCurrency)
            .map { $0.compactMap(RecurringBuy.init) }
            .eraseToAnyPublisher()
    }
}
