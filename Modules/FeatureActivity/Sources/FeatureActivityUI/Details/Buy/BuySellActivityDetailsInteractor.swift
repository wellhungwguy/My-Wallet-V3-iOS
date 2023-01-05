// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import FeatureActivityDomain
import FeatureTransactionDomain
import MoneyKit
import PlatformKit

final class BuySellActivityDetailsInteractor {

    private let cardDataService: ActivityCardDataServiceAPI
    private let ordersService: OrdersServiceAPI
    private let recurringBuyProviderRepository: RecurringBuyProviderRepositoryAPI

    init(
        cardDataService: ActivityCardDataServiceAPI,
        ordersService: OrdersServiceAPI,
        recurringBuyProviderRepository: RecurringBuyProviderRepositoryAPI
    ) {
        self.cardDataService = cardDataService
        self.ordersService = ordersService
        self.recurringBuyProviderRepository = recurringBuyProviderRepository
    }

    func fetchCardDisplayName(for paymentMethodId: String?) -> AnyPublisher<String?, Never> {
        guard let paymentMethodId else {
            return .just(nil)
        }
        return cardDataService
            .fetchCardDisplayName(for: paymentMethodId)
    }

    func fetchRecurringBuyFrequencyForId(_ recurringBuyId: String) -> AnyPublisher<String, Error> {
        recurringBuyProviderRepository
            .fetchRecurringBuyWithRecurringBuyId(recurringBuyId)
            .compactMap(\.nextPaymentDateDescription)
            .eraseError()
            .eraseToAnyPublisher()
    }

    func fetchPrice(for orderId: String) -> AnyPublisher<MoneyValue?, OrdersServiceError> {
        ordersService
            .fetchOrder(with: orderId)
            .map(\.price)
            .eraseToAnyPublisher()
    }
}
