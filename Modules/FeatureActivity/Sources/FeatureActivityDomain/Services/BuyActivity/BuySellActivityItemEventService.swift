// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import MoneyKit
import PlatformKit

final class BuySellActivityItemEventService: BuySellActivityItemEventServiceAPI {

    private let ordersService: OrdersServiceAPI
    private let kycTiersService: KYCTiersServiceAPI
    private var isTier2Approved: AnyPublisher<Bool, Never> {
        kycTiersService
            .tiers
            .map(\.isTier2Approved)
            .replaceError(with: false)
            .eraseToAnyPublisher()
    }

    init(
        ordersService: OrdersServiceAPI,
        kycTiersService: KYCTiersServiceAPI
    ) {
        self.ordersService = ordersService
        self.kycTiersService = kycTiersService
    }

    func buySellActivityEvents(cryptoCurrency: CryptoCurrency) -> AnyPublisher<[BuySellActivityItemEvent], OrdersServiceError> {
        isTier2Approved
            .setFailureType(to: OrdersServiceError.self)
            .flatMap { [ordersService] isTier2Approved -> AnyPublisher<[BuySellActivityItemEvent], OrdersServiceError> in
                guard isTier2Approved else {
                    return .just([])
                }
                return ordersService.orders
                    .map { orders -> [BuySellActivityItemEvent] in
                        orders
                            .filter { order in
                                order.outputValue.currency == cryptoCurrency
                                || order.inputValue.currency == cryptoCurrency
                            }
                            .map(BuySellActivityItemEvent.init(with:))
                    }
                    .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }
}
