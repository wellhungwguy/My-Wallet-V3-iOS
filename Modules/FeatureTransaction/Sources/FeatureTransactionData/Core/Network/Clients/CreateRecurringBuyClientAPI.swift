import Combine
import Errors
import FeatureTransactionDomain
import MoneyKit
import PlatformKit

protocol CreateRecurringBuyClientAPI {
    func createRecurringBuyWithFiatValue(
        _ fiatValue: FiatValue,
        cryptoCurrency: CryptoCurrency,
        frequency: RecurringBuy.Frequency,
        paymentMethod: PaymentMethodType
    ) -> AnyPublisher<RecurringBuyResponse, NabuNetworkError>
}
