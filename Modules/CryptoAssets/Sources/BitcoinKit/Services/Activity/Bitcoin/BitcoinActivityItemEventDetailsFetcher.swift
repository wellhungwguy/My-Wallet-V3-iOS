// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BitcoinChainKit
import DIKit
import MoneyKit
import PlatformKit
import RxSwift

final class BitcoinActivityItemEventDetailsFetcher: ActivityItemEventDetailsFetcherAPI {
    typealias Model = BitcoinActivityItemEventDetails

    private let repository: BitcoinWalletAccountRepository
    private let transactionsService: BitcoinHistoricalTransactionServiceAPI

    init(
        transactionsService: BitcoinHistoricalTransactionServiceAPI = resolve(),
        repository: BitcoinWalletAccountRepository = resolve()
    ) {
        self.transactionsService = transactionsService
        self.repository = repository
    }

    func details(
        for identifier: String,
        cryptoCurrency: CryptoCurrency
    ) -> Observable<BitcoinActivityItemEventDetails> {
        repository.accounts
            .map { accounts -> [XPub] in
                accounts.map(\.publicKeys).flatMap(\.xpubs)
            }
            .eraseError()
            .flatMap { [transactionsService] publicKeys in
                transactionsService
                    .transaction(publicKeys: publicKeys, identifier: identifier)
                    .map(BitcoinActivityItemEventDetails.init(transaction:))
            }
            .asObservable()
    }
}
