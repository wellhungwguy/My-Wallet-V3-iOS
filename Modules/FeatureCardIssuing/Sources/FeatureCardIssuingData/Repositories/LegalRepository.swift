// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import Errors
import FeatureCardIssuingDomain
import Foundation
import NetworkKit
import ToolKit

final class LegalRepository: LegalRepositoryAPI {

    private let client: LegalClientAPI

    private struct Key: Hashable {}

    private let cache: AnyCache<Key, [LegalItem]>
    private let cachedValue: CachedValueNew<
        Key,
        [LegalItem],
        NabuNetworkError
    >

    init(
        client: LegalClientAPI
    ) {
        self.client = client

        let cache: AnyCache<Key, [LegalItem]> = InMemoryCache(
            configuration: .onLoginLogoutDebitCardRefresh(),
            refreshControl: PerpetualCacheRefreshControl()
        ).eraseToAnyCache()

        self.cache = cache

        cachedValue = CachedValueNew(
            cache: cache,
            fetch: { _ in
                client.fetchLegalItems()
            }
        )
    }

    func fetchLegalItems() -> AnyPublisher<[LegalItem], NabuNetworkError> {
        cachedValue.get(key: Key())
    }

    func setAccepted(legalItems: [LegalItem]) -> AnyPublisher<[LegalItem], NabuNetworkError> {
        client
            .setAccepted(legalItems: legalItems)
            .flatMap { items -> AnyPublisher<[LegalItem], NabuNetworkError> in
                self.cache
                    .set(items, for: Key())
                    .setFailureType(to: NabuNetworkError.self)
                    .map { _ -> [LegalItem] in
                        items
                    }
                    .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }
}
