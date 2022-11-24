// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import ToolKit

protocol StellarAccountDetailsRepositoryAPI {
    func details(
        accountID: String
    ) -> AnyPublisher<StellarAccountDetails, StellarNetworkError>

    func invalidateCache()
}

final class StellarAccountDetailsRepository: StellarAccountDetailsRepositoryAPI {

    // MARK: Private Properties

    private let cachedValue: CachedValueNew<String, StellarAccountDetails, StellarNetworkError>
    private let horizonProxy: HorizonProxyAPI

    // MARK: Init

    init(horizonProxy: HorizonProxyAPI) {
        self.horizonProxy = horizonProxy
        let cache: AnyCache<String, StellarAccountDetails> = InMemoryCache(
            configuration: .onLoginLogout(),
            refreshControl: PeriodicCacheRefreshControl(refreshInterval: 20)
        ).eraseToAnyCache()
        self.cachedValue = CachedValueNew(
            cache: cache,
            fetch: { accountID -> AnyPublisher<StellarAccountDetails, StellarNetworkError> in
                horizonProxy
                    .accountResponse(for: accountID)
                    .map { [horizonProxy] response -> StellarAccountDetails in
                        let minBalance = horizonProxy.minimumBalance(subentryCount: response.subentryCount)
                        return response.toAssetAccountDetails(minimumBalance: minBalance)
                    }
                    .catch { error -> AnyPublisher<StellarAccountDetails, StellarNetworkError> in
                        // If the network call to Horizon fails due to there not being a default account
                        // (i.e. account is not yet funded), catch that error (StellarNetworkError.notFound)
                        // and return a StellarAccount with 0 balance.
                        switch error {
                        case .notFound:
                            return .just(.unfunded(accountID: accountID))
                        case .horizonRequestError,
                             .parsingFailed,
                             .destinationRequiresMemo:
                            return .failure(error)
                        }
                    }
                    .eraseToAnyPublisher()
            }
        )
    }

    func details(
        accountID: String
    ) -> AnyPublisher<StellarAccountDetails, StellarNetworkError> {
        cachedValue.get(key: accountID)
    }

    func invalidateCache() {
        cachedValue.invalidateCache()
    }
}
