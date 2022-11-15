import Combine
import Errors
import FeatureTransactionDomain
import MoneyKit
import PlatformKit

protocol EligiblePaymentMethodRecurringBuyClientAPI {
    func fetchEligiblePaymentMethodTypesStartingFromDate(
        _ date: Date?
    ) -> AnyPublisher<EligiblePaymentMethodsRecurringBuyResponse, NabuNetworkError>
}
