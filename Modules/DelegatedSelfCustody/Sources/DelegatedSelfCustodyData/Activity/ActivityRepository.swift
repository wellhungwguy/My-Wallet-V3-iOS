// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import DelegatedSelfCustodyDomain
import Foundation
import MoneyKit
import ToolKit

final class ActivityRepository: DelegatedCustodyActivityRepositoryAPI {

    private let client: AccountDataClientAPI
    private let authenticationDataRepository: AuthenticationDataRepositoryAPI
    private let cachedValue: CachedValueNew<
        CryptoCurrency,
        [DelegatedCustodyActivity],
        Error
    >

    init(
        client: AccountDataClientAPI,
        authenticationDataRepository: AuthenticationDataRepositoryAPI
    ) {
        self.client = client
        self.authenticationDataRepository = authenticationDataRepository
        let cache: AnyCache<CryptoCurrency, [DelegatedCustodyActivity]> = InMemoryCache(
            configuration: .onLoginLogoutTransaction(),
            refreshControl: PeriodicCacheRefreshControl(refreshInterval: 30)
        ).eraseToAnyCache()
        cachedValue = CachedValueNew(
            cache: cache,
            fetch: { [authenticationDataRepository, client] key in
                authenticationDataRepository.authenticationData
                    .flatMap { [client] authenticationData in
                        client.transactionHistory(
                            guidHash: authenticationData.guidHash,
                            sharedKeyHash: authenticationData.sharedKeyHash,
                            currency: key.code,
                            identifier: nil
                        )
                        .eraseError()
                    }
                    .map { response in
                        DelegatedCustodyActivity
                            .create(from: response, cryptoCurrency: key)
                            .sorted(by: { lhs, rhs in
                                lhs.timestamp > rhs.timestamp
                            })
                    }
                    .eraseToAnyPublisher()
            }
        )
    }

    func activity(for cryptoCurrency: CryptoCurrency) -> AnyPublisher<[DelegatedCustodyActivity], Error> {
        cachedValue.get(key: cryptoCurrency)
    }
}

extension DelegatedCustodyActivity {
    static func create(
        from response: TransactionHistoryResponse,
        cryptoCurrency: CryptoCurrency
    ) -> [DelegatedCustodyActivity] {
        response.history.map { entry in
            DelegatedCustodyActivity(entry: entry, cryptoCurrency: cryptoCurrency)
        }
    }

    init(entry: TransactionHistoryResponse.Entry, cryptoCurrency: CryptoCurrency) {
        let sourceAddress = entry.movements
            .first { movement in
                movement.type == .sent
            }?
            .address
        let targetAddress = entry.movements
            .first { movement in
                movement.type == .received
            }?
            .address
        let status = DelegatedCustodyActivity.Status(response: entry.status)
        let timestamp = entry.timestamp
            .flatMap(Date.init(timeIntervalSince1970:)) ?? Date()
        let zero = CryptoValue.zero(currency: cryptoCurrency)
        let value = (entry.movements.first?.amount)
            .flatMap { CryptoValue.create(minor: $0, currency: cryptoCurrency) } ?? zero
        let fee = CryptoValue.create(minor: entry.fee, currency: cryptoCurrency) ?? zero

        self.init(
            coin: cryptoCurrency,
            fee: fee,
            from: sourceAddress ?? "",
            status: status,
            timestamp: timestamp,
            to: targetAddress ?? "",
            transactionID: entry.txId,
            value: value
        )
    }
}

extension DelegatedCustodyActivity.Status {
    init(response: TransactionHistoryResponse.Status?) {
        switch response {
        case nil:
            self = .pending
        case .failed:
            self = .failed
        case .completed:
            self = .completed
        case .confirming:
            self = .confirming
        case .pending:
            self = .pending
        }
    }
}
