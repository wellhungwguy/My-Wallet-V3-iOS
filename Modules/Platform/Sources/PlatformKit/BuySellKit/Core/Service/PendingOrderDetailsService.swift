// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import DIKit
import ToolKit

public protocol PendingOrderDetailsServiceAPI: AnyObject {
    var pendingOrderDetails: AnyPublisher<[OrderDetails], OrdersServiceError> { get }
    var pendingActionOrderDetails: AnyPublisher<[OrderDetails], OrdersServiceError> { get }

    func cancel(_ order: OrderDetails) -> AnyPublisher<Void, OrderCancellationError>
}

final class PendingOrderDetailsService: PendingOrderDetailsServiceAPI {

    var pendingOrderDetails: AnyPublisher<[OrderDetails], OrdersServiceError> {
        ordersService.fetchOrders()
            .map { orders in
                orders
                    .filter { !$0.isFinal }
                    .filter { $0.isAwaitingAction || $0.is3DSConfirmedCardOrder }
            }
            .eraseToAnyPublisher()
    }

    var pendingActionOrderDetails: AnyPublisher<[OrderDetails], OrdersServiceError> {
        ordersService.fetchOrders()
            .map { orders in
                orders
                    .filter { !$0.isFinal }
                    .filter(\.isAwaitingAction)
            }
            .eraseToAnyPublisher()
    }

    // MARK: - Injected

    private let ordersService: OrdersServiceAPI
    private let cancallationService: OrderCancellationServiceAPI

    // MARK: - Setup

    init(
        ordersService: OrdersServiceAPI = resolve(),
        cancallationService: OrderCancellationServiceAPI = resolve()
    ) {
        self.ordersService = ordersService
        self.cancallationService = cancallationService
    }

    func cancel(_ order: OrderDetails) -> AnyPublisher<Void, OrderCancellationError> {
        cancallationService.cancelOrder(with: order.identifier)
    }
}
