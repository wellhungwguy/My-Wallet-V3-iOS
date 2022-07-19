// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import Errors
import Foundation

final class TransactionService: TransactionServiceAPI {

    private let repository: TransactionRepositoryAPI

    init(
        repository: TransactionRepositoryAPI
    ) {
        self.repository = repository
    }

    func fetchTransactions(for card: Card?) -> AnyPublisher<[Card.Transaction], NabuNetworkError> {
        repository.fetchTransactions(for: card)
    }

    func fetchMore(for card: Card?) -> AnyPublisher<[Card.Transaction], NabuNetworkError> {
        repository.fetchMore(for: card)
    }
}
