// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import Errors
import MoneyKit
import PlatformKit

protocol CreateRecurringBuyServiceAPI {
    func createRecurringBuyWithFiatValue(
        _ fiatValue: FiatValue,
        cryptoCurrency: CryptoCurrency,
        frequency: RecurringBuy.Frequency,
        paymentMethod: PaymentMethodType
    ) -> AnyPublisher<RecurringBuy, NabuNetworkError>
}
