// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import ToolKit

protocol StellarConfigurationServiceAPI {
    var configuration: AnyPublisher<StellarConfiguration, Never> { get }
}

final class StellarConfigurationService: StellarConfigurationServiceAPI {

    // MARK: Private Types

    private typealias KeyType = String

    // MARK: Properties

    var configuration: AnyPublisher<StellarConfiguration, Never> {
        cachedValue.get(key: KeyType())
    }

    // MARK: Private Properties

    private let walletOptions: StellarWalletOptionsBridgeAPI
    private let cachedValue: CachedValueNew<KeyType, StellarConfiguration, Never>

    // MARK: Init

    init(walletOptions: StellarWalletOptionsBridgeAPI) {
        self.walletOptions = walletOptions
        let cache: AnyCache<KeyType, StellarConfiguration> = InMemoryCache(
            configuration: .onLoginLogout(),
            refreshControl: PerpetualCacheRefreshControl()
        ).eraseToAnyCache()
        self.cachedValue = CachedValueNew(
            cache: cache,
            fetch: { _ -> AnyPublisher<StellarConfiguration, Never> in
                walletOptions.stellarConfigurationDomain
                    .map { horizonURL -> StellarConfiguration? in
                        horizonURL.flatMap(StellarConfiguration.init(horizonURL:))
                    }
                    .replaceNil(with: .Blockchain.production)
                    .replaceError(with: .Blockchain.production)
                    .eraseToAnyPublisher()
            }
        )
    }
}
