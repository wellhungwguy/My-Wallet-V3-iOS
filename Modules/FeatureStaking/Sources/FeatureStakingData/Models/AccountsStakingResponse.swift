// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import FeatureStakingDomain
import Foundation
import MoneyKit

struct StakingAccountBalanceResponse: Decodable {
    let balance: String?
    let pendingDeposit: String?
    let pendingWithdrawal: String?
    let totalRewards: String?
    let pendingRewards: String?
    let bondingDeposits: String?
    let unbondingWithdrawals: String?
    let locked: String?
}

struct StakingAccountsResponse: Decodable {

    static let empty = StakingAccountsResponse()

    let balances: [String: StakingAccountBalanceResponse]

    private init() {
        balances = [:]
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        balances = try container.decode([String: StakingAccountBalanceResponse].self)
    }

    // MARK: - Subscript

    subscript(currency: CryptoCurrency) -> StakingAccountBalanceResponse? {
        balances[currency.code]
    }
}

extension StakingAccountBalances {
    init(_ response: StakingAccountsResponse) {
        var balances: [String: StakingAccountBalanceDetail] = [:]
        response.balances.keys.forEach { key in
            balances[key] = StakingAccountBalanceDetail(
                response.balances[key]!,
                code: key
            )
        }
        self.init(balances: balances)
    }
}

extension StakingAccountBalanceDetail {
    init(_ response: StakingAccountBalanceResponse, code: String) {
        self.init(
            balance: response.balance,
            pendingDeposit: response.pendingDeposit,
            pendingWithdrawal: response.pendingWithdrawal,
            totalRewards: response.totalRewards,
            pendingRewards: response.pendingRewards,
            bondingDeposits: response.bondingDeposits,
            unbondingWithdrawals: response.unbondingWithdrawals,
            locked: response.locked,
            code: code
        )
    }
}
