// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import MoneyKit

public struct StakingAccountBalances: Equatable {

    public static let empty = StakingAccountBalances()

    // MARK: - Properties

    public let balances: [String: StakingAccountBalanceDetail]

    // MARK: - Init

    public init(balances: [String: StakingAccountBalanceDetail]) {
        self.balances = balances
    }

    private init() {
        balances = [:]
    }

    // MARK: - Subscript

    public subscript(currency: CryptoCurrency) -> StakingAccountBalanceDetail? {
        balances[currency.code]
    }
}
