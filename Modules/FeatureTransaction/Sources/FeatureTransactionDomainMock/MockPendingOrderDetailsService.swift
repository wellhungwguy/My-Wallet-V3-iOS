// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import FeatureTransactionDomain
import PlatformKit
import ToolKit

public final class MockPendingOrderDetailsService: PendingOrderDetailsServiceAPI {

    public struct StubbedResults {
        public var pendingOrderDetails: AnyPublisher<[OrderDetails], OrdersServiceError> = .just([])
        public var pendingActionOrderDetails: AnyPublisher<[OrderDetails], OrdersServiceError> = .just([])
        public var cancel: AnyPublisher<Void, OrderCancellationError> = .just(())
    }

    public var stubbedResults = StubbedResults()

    public var pendingOrderDetails: AnyPublisher<[OrderDetails], OrdersServiceError> {
        stubbedResults.pendingOrderDetails
    }

    public var pendingActionOrderDetails: AnyPublisher<[OrderDetails], OrdersServiceError> {
        stubbedResults.pendingActionOrderDetails
    }

    public func cancel(_ order: OrderDetails) -> AnyPublisher<Void, OrderCancellationError> {
        stubbedResults.cancel
    }
}
