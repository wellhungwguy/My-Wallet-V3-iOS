// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import Errors
import Foundation

public protocol TransactionServiceAPI {

    func fetchTransactions(for card: Card?) -> AnyPublisher<[Card.Transaction], NabuNetworkError>

    func fetchMore(for card: Card?) -> AnyPublisher<[Card.Transaction], NabuNetworkError>
}

extension TransactionServiceAPI {

    public func fetchTransactions() -> AnyPublisher<[Card.Transaction], NabuNetworkError> {
        fetchTransactions(for: nil)
    }

    public func fetchMore() -> AnyPublisher<[Card.Transaction], NabuNetworkError> {
        fetchMore(for: nil)
    }
}
