// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import Errors
import FeatureCardIssuingDomain
import Foundation
import ToolKit

final class TransactionRepository: TransactionRepositoryAPI {

    private struct Key: Hashable {
        let cardId: String?
    }

    private static let defaultKey = "all-debit-card-transactions"
    private let cachedValue: CachedValueNew<Key, [Card.Transaction], NabuNetworkError>
    private let cache: AnyCache<Key, [Card.Transaction]>

    private let client: TransactionClientAPI

    init(client: TransactionClientAPI) {
        self.client = client

        let cache: AnyCache<Key, [Card.Transaction]> = InMemoryCache(
            configuration: .onLoginLogoutDebitCardRefresh(),
            refreshControl: PerpetualCacheRefreshControl()
        ).eraseToAnyCache()

        self.cache = cache

        cachedValue = CachedValueNew(
            cache: cache,
            fetch: { key in
                client.fetchTransactions(
                    TransactionsParams(cardId: key.cardId)
                )
            }
        )
    }

    func fetchTransactions(for card: Card?) -> AnyPublisher<[Card.Transaction], NabuNetworkError> {
        cachedValue.get(key: Key(cardId: card?.id))
    }

    func fetchMore(for card: Card?) -> AnyPublisher<[Card.Transaction], NabuNetworkError> {
        cachedValue
            .get(key: Key(cardId: card?.id))
            .flatMap { [weak self] transactions -> AnyPublisher<[Card.Transaction], NabuNetworkError> in
                guard let self = self else {
                    return .empty()
                }

                guard let transaction = transactions.last else {
                    return self.client.fetchTransactions()
                }

                return self.client
                    .fetchTransactions(
                        TransactionsParams(toId: transaction.id)
                    )
                    .flatMap { requestedTransactions -> AnyPublisher<[Card.Transaction], NabuNetworkError> in
                        let mergedTransactions = transactions + requestedTransactions
                        return self.cache
                            .set(mergedTransactions, for: Key(cardId: card?.id))
                            .map { _ in mergedTransactions }
                            .setFailureType(to: NabuNetworkError.self)
                            .eraseToAnyPublisher()
                    }
                    .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }
}
