// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import Errors
import Foundation

public protocol TransactionRepositoryAPI {

    func fetchTransactions(for card: Card?) -> AnyPublisher<[Card.Transaction], NabuNetworkError>

    func fetchMore(for card: Card?) -> AnyPublisher<[Card.Transaction], NabuNetworkError>
}
