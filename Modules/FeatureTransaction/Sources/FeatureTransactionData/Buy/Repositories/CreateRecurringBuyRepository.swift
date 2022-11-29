// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import Errors
import FeatureTransactionDomain
import MoneyKit
import PlatformKit

final class CreateRecurringBuyRepository: CreateRecurringBuyRepositoryAPI {

    private let client: CreateRecurringBuyClientAPI

    init(client: CreateRecurringBuyClientAPI) {
        self.client = client
    }

    // MARK: - CreateRecurringBuyRepositoryAPI

    func createRecurringBuyWithFiatValue(
        _ fiatValue: FiatValue,
        cryptoCurrency: CryptoCurrency,
        frequency: RecurringBuy.Frequency,
        paymentMethod: PaymentMethodType
    ) -> AnyPublisher<RecurringBuy, NabuNetworkError> {
        client
            .createRecurringBuyWithFiatValue(
                fiatValue,
                cryptoCurrency: cryptoCurrency,
                frequency: frequency,
                paymentMethod: paymentMethod
            )
            .compactMap(RecurringBuy.init)
            .eraseToAnyPublisher()
    }
}
