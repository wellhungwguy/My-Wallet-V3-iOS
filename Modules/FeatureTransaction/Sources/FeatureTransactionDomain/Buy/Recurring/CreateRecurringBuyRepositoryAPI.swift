// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import Errors
import MoneyKit
import PlatformKit

public protocol CreateRecurringBuyRepositoryAPI {
    func createRecurringBuyWithFiatValue(
        _ fiatValue: FiatValue,
        cryptoCurrency: CryptoCurrency,
        frequency: RecurringBuy.Frequency,
        paymentMethod: PaymentMethodType
    ) -> AnyPublisher<RecurringBuy, NabuNetworkError>
}
