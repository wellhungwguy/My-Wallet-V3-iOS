// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BigInt
import Combine
import DIKit
import Errors
import FeatureWithdrawalLocksDomain
import Foundation

final class WithdrawalLocksRepository: WithdrawalLocksRepositoryAPI {

    private let client: WithdrawalLocksClientAPI
    private let moneyValueFormatter: MoneyValueFormatterAPI
    private let cryptoValueFormatter: CryptoValueFormatterAPI

    private let decodingDateFormatter = DateFormatter.sessionDateFormat
    private let encodingDateFormatter = DateFormatter.shortWithoutYear

    init(
        client: WithdrawalLocksClientAPI = resolve(),
        moneyValueFormatter: MoneyValueFormatterAPI = resolve(),
        cryptoValueFormatter: CryptoValueFormatterAPI = resolve()
    ) {
        self.client = client
        self.moneyValueFormatter = moneyValueFormatter
        self.cryptoValueFormatter = cryptoValueFormatter
    }

    func withdrawalLocks(
        currencyCode: String
    ) -> AnyPublisher<WithdrawalLocks, Never> {
        client.fetchWithdrawalLocks(currencyCode: currencyCode)
            .ignoreFailure()
            .map { [encodingDateFormatter, decodingDateFormatter, moneyValueFormatter, cryptoValueFormatter] withdrawalLocks in
                WithdrawalLocks(
                    items: withdrawalLocks.locks.compactMap { lock in
                        guard let fromDate = decodingDateFormatter.date(from: lock.expiresAt) else {
                            return nil
                        }
                        return .init(
                            date: encodingDateFormatter.string(
                                from: fromDate
                            ),
                            amount: moneyValueFormatter.formatMoney(
                                amount: lock.amount.amount,
                                currency: lock.amount.currency
                            ),
                            amountCurrency: lock.amount.currency,
                            boughtAmount: lock.bought.map {
                                cryptoValueFormatter.format(
                                    amount: $0.amount,
                                    currency: $0.currency
                                )
                            },
                            boughtCryptoCurrency: lock.bought?.currency
                        )
                    },
                    amount: moneyValueFormatter.formatMoney(
                        amount: withdrawalLocks.totalLocked.amount,
                        currency: withdrawalLocks.totalLocked.currency
                    )
                )
            }
            .eraseToAnyPublisher()
    }
}
