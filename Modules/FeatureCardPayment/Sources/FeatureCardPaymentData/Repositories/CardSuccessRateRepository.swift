// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import DIKit
import Errors
import FeatureCardPaymentDomain
import Foundation
import ToolKit

class CardSuccessRateRepository: CardSuccessRateRepositoryAPI {

    private struct Key: Hashable {
        let binNumber: String
    }

    private let cachedValue: CachedValueNew<
        Key,
        CardSuccessRateData,
        NabuNetworkError
    >

    init(cardSuccessRateClient: CardSuccessRateClientAPI = resolve()) {
        let cache: AnyCache<Key, CardSuccessRateData> = InMemoryCache(
            configuration: .onLoginLogout(),
            refreshControl: PerpetualCacheRefreshControl()
        ).eraseToAnyCache()

        self.cachedValue = CachedValueNew(
            cache: cache,
            fetch: { key in
                cardSuccessRateClient
                    .getCardSuccessRate(binNumber: key.binNumber)
                    .map(CardSuccessRateData.init(response:))
                    .eraseToAnyPublisher()
            }
        )
    }

    func getCardSuccessRate(
        binNumber: String
    ) -> AnyPublisher<CardSuccessRateData, NabuNetworkError> {
        cachedValue
            .get(key: .init(binNumber: binNumber))
    }
}
