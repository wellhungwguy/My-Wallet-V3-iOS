import Combine
import Errors
import FeatureTransactionDomain
import MoneyKit
import PlatformKit

protocol RecurringBuyProviderClientAPI {
    func fetchRecurringBuysForCryptoCurrency(
        _ cryptoCurrency: CryptoCurrency
    ) -> AnyPublisher<[RecurringBuyResponse], NabuNetworkError>
}
