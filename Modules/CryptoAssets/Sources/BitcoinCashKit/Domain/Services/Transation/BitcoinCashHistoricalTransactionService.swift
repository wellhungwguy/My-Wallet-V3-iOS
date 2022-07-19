// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BitcoinChainKit
import Combine
import DIKit
import Errors
import PlatformKit
import ToolKit

protocol BitcoinCashHistoricalTransactionServiceAPI: AnyObject {
    func transactions(publicKeys: [XPub]) -> AnyPublisher<[BitcoinCashHistoricalTransaction], NetworkError>
    func transaction(publicKeys: [XPub], identifier: String) -> AnyPublisher<BitcoinCashHistoricalTransaction, Error>
}

final class BitcoinCashHistoricalTransactionService: BitcoinCashHistoricalTransactionServiceAPI {

    private enum ServiceError: Error {
        case errorFetchingDetails
    }

    private let client: APIClientAPI
    private let cachedValue: CachedValueNew<
        Set<XPub>,
        [BitcoinCashHistoricalTransaction],
        NetworkError
    >

    init(with client: APIClientAPI = resolve()) {
        self.client = client
        let cache: AnyCache<Set<XPub>, [BitcoinCashHistoricalTransaction]> = InMemoryCache(
            configuration: .onLoginLogoutTransaction(),
            refreshControl: PeriodicCacheRefreshControl(refreshInterval: 60)
        ).eraseToAnyCache()
        cachedValue = CachedValueNew(
            cache: cache,
            fetch: { [client] xPubs in
                client
                    .multiAddress(for: Array(xPubs))
                    .map(\.transactions)
                    .eraseToAnyPublisher()
            }
        )
    }

    func transactions(publicKeys: [XPub]) -> AnyPublisher<[BitcoinCashHistoricalTransaction], NetworkError> {
        cachedValue
            .get(key: Set(publicKeys))
    }

    // It is not possible to fetch a specific transaction detail from 'multiaddr' endpoints,
    //   so we fetch the first page and filter out the transaction from there.
    //   This may cause a edge case where a user opens the last transaction of the list, but
    //   in the mean time there was a new transaction added, making it 'drop' out of the first
    //   page. The fix for this is to have a properly paginated multiaddr/details endpoint.
    func transaction(publicKeys: [XPub], identifier: String) -> AnyPublisher<BitcoinCashHistoricalTransaction, Error> {
        transactions(publicKeys: publicKeys)
            .map { items -> BitcoinCashHistoricalTransaction? in
                items.first { $0.identifier == identifier }
            }
            .eraseError()
            .onNil(ServiceError.errorFetchingDetails)
    }
}
