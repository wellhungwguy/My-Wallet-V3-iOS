// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import DIKit
import MoneyKit
import ToolKit

public protocol ExchangeAccountsProviderAPI {

    func account(
        for currency: CryptoCurrency,
        externalAssetAddressFactory: ExternalAssetAddressFactory
    ) -> AnyPublisher<CryptoExchangeAccount, ExchangeAccountsNetworkError>
}

final class ExchangeAccountsProvider: ExchangeAccountsProviderAPI {

    // MARK: - Private Properties

    private let statusService: ExchangeAccountStatusServiceAPI
    private let client: ExchangeAccountsProviderClientAPI
    private let cachedValue: CachedValueNew<
        CryptoCurrency,
        CryptoExchangeAddressResponse,
        ExchangeAccountsNetworkError
    >

    // MARK: - Init

    init(
        client: ExchangeAccountsClientAPI = resolve(),
        statusService: ExchangeAccountStatusServiceAPI = resolve()
    ) {
        self.statusService = statusService
        self.client = client
        let cache: AnyCache<CryptoCurrency, CryptoExchangeAddressResponse> = InMemoryCache(
            configuration: .onLoginLogout(),
            refreshControl: PerpetualCacheRefreshControl()
        ).eraseToAnyCache()
        self.cachedValue = CachedValueNew(
            cache: cache,
            fetch: { [statusService, client] key in
                statusService
                    .hasLinkedExchangeAccount
                    .replaceError(with: ExchangeAccountsNetworkError.unavailable)
                    .flatMap { hasLinkedExchangeAccount
                        -> AnyPublisher<CryptoExchangeAddressResponse, ExchangeAccountsNetworkError> in
                        guard hasLinkedExchangeAccount else {
                            return .failure(ExchangeAccountsNetworkError.missingAccount)
                        }
                        return client.exchangeAddress(with: key)
                            .replaceError(with: ExchangeAccountsNetworkError.missingAccount)
                            .eraseToAnyPublisher()
                    }
                    .eraseToAnyPublisher()
            }
        )
    }

    // MARK: - ExchangeAccountsProviderAPI

    func account(
        for currency: CryptoCurrency,
        externalAssetAddressFactory: ExternalAssetAddressFactory
    ) -> AnyPublisher<CryptoExchangeAccount, ExchangeAccountsNetworkError> {
        guard currency.supports(product: .mercuryDeposits) else {
            return .failure(ExchangeAccountsNetworkError.unavailable)
        }
        return cachedValue.get(key: currency)
            .map { response in
                CryptoExchangeAccount(
                    response: response,
                    cryptoReceiveAddressFactory: externalAssetAddressFactory
                )
            }
            .eraseToAnyPublisher()
    }
}
