//
//  PendingOrderDetailsService.swift
//  PlatformKit
//
//  Created by Daniel Huri on 18/02/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import DIKit
import RxSwift
import ToolKit

public protocol PendingOrderDetailsServiceAPI: class {
    var pendingOrderDetails: Single<OrderDetails?> { get }
    var pendingActionOrderDetails: Single<OrderDetails?> { get }
    func cancel() -> Completable
}

final class PendingOrderDetailsService: PendingOrderDetailsServiceAPI {
        
    var pendingOrderDetails: Single<OrderDetails?> {
        ordersService.fetchOrders()
            .map { orders in
                orders
                    .filter { !$0.isFinal }
                    .filter { $0.isAwaitingAction || $0.is3DSConfirmedCardOrder }
            }
            .map { $0.first }
    }
    
    var pendingActionOrderDetails: Single<OrderDetails?> {
        ordersService.fetchOrders()
            .map { orders in
                orders
                    .filter { !$0.isFinal }
                    .filter { $0.isAwaitingAction }
            }
            .map { $0.first }
    }
    
    // MARK: - Injected
    
    private let ordersService: OrdersServiceAPI
    private let cancallationService: OrderCancellationServiceAPI
    
    // MARK: - Setup
    
    init(ordersService: OrdersServiceAPI = resolve(),
         cancallationService: OrderCancellationServiceAPI = resolve()) {
        self.ordersService = ordersService
        self.cancallationService = cancallationService
    }
    
    func cancel() -> Completable {
        pendingOrderDetails
            .flatMapCompletable(weak: self) { (self, details) -> Completable in
                guard let details = details else { return .empty() }
                return self.cancallationService.cancel(order: details.identifier)
            }
    }
}
