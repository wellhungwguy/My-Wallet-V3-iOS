// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import Errors
import MoneyKit
import PlatformKit

final class CreateRecurringBuyService: CreateRecurringBuyServiceAPI {

    private let repository: CreateRecurringBuyRepositoryAPI

    init(repository: CreateRecurringBuyRepositoryAPI) {
        self.repository = repository
    }

    // MARK: - CreateRecurringBuyServiceAPI

    func createRecurringBuyWithFiatValue(
        _ fiatValue: FiatValue,
        cryptoCurrency: CryptoCurrency,
        frequency: RecurringBuy.Frequency,
        paymentMethod: PaymentMethodType
    ) -> AnyPublisher<RecurringBuy, NabuNetworkError> {
        repository
            .createRecurringBuyWithFiatValue(
                fiatValue,
                cryptoCurrency: cryptoCurrency,
                frequency: frequency,
                paymentMethod: paymentMethod
            )
    }
}
