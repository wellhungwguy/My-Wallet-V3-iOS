// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import DelegatedSelfCustodyDomain
import Foundation
import MoneyKit
import ToolKit

protocol AccountRepositoryAPI: DelegatedCustodyAccountRepositoryAPI {

    func accounts() -> AnyPublisher<[DelegatedCustodyAccount], Error>
}

final class AccountRepository: AccountRepositoryAPI {

    private struct Key: Hashable {}

    private let assetSupportService: AssetSupportService
    private let derivationService: DelegatedCustodyDerivationServiceAPI
    private let enabledCurrenciesService: EnabledCurrenciesServiceAPI
    private let cachedValue: CachedValueNew<Key, [DelegatedCustodyAccount], Error>

    init(
        assetSupportService: AssetSupportService,
        derivationService: DelegatedCustodyDerivationServiceAPI,
        enabledCurrenciesService: EnabledCurrenciesServiceAPI
    ) {
        self.assetSupportService = assetSupportService
        self.derivationService = derivationService
        self.enabledCurrenciesService = enabledCurrenciesService

        let cache: AnyCache<Key, [DelegatedCustodyAccount]> = InMemoryCache(
            configuration: .onLoginLogout(),
            refreshControl: PerpetualCacheRefreshControl()
        ).eraseToAnyCache()

        cachedValue = CachedValueNew(
            cache: cache,
            fetch: { _ in
                assetSupportService
                    .supportedDerivations()
                    .flatMap { supportedAssets -> AnyPublisher<[DelegatedCustodyAccount], Error> in
                        supportedAssets
                            .compactMap { asset -> AnyPublisher<DelegatedCustodyAccount, Error>? in
                                guard let cryptoCurrency = CryptoCurrency(
                                    code: asset.currencyCode,
                                    enabledCurrenciesService: enabledCurrenciesService
                                ) else {
                                    return nil
                                }
                                return derivationService.getKeys(path: asset.derivationPath)
                                    .map { keys in
                                        DelegatedCustodyAccount(
                                            coin: cryptoCurrency,
                                            derivationPath: asset.derivationPath,
                                            style: asset.style,
                                            publicKey: keys.publicKey,
                                            privateKey: keys.privateKey
                                        )
                                    }
                                    .eraseToAnyPublisher()
                            }
                            .zip()
                    }
                    .eraseToAnyPublisher()
            }
        )
    }

    func accounts() -> AnyPublisher<[DelegatedCustodyAccount], Error> {
        cachedValue.get(key: Key())
    }

    func accountsCurrencies() -> AnyPublisher<[CryptoCurrency], Error> {
        cachedValue.get(key: Key())
            .map { accounts in
                accounts.map(\.coin)
            }
            .eraseToAnyPublisher()
    }
}
