// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import FeatureActivityDomain
import MoneyKit
import PlatformKit

final class BuySellActivityDetailsInteractor {

    private let cardDataService: ActivityCardDataServiceAPI
    private let ordersService: OrdersServiceAPI

    init(
        cardDataService: ActivityCardDataServiceAPI,
        ordersService: OrdersServiceAPI
    ) {
        self.cardDataService = cardDataService
        self.ordersService = ordersService
    }

    func fetchCardDisplayName(for paymentMethodId: String?) -> AnyPublisher<String?, Never> {
        guard let paymentMethodId = paymentMethodId else {
            return .just(nil)
        }
        return cardDataService
            .fetchCardDisplayName(for: paymentMethodId)
    }

    func fetchPrice(for orderId: String) -> AnyPublisher<MoneyValue?, OrdersServiceError> {
        ordersService
            .fetchOrder(with: orderId)
            .map(\.price)
            .eraseToAnyPublisher()
    }
}
