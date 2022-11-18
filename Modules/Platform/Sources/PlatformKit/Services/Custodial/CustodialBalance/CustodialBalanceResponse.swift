// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation
import MoneyKit

public struct CustodialBalanceResponse: Decodable {

    // MARK: - Types

    public struct Balance: Decodable {
        public let pending: String
        public let pendingDeposit: String
        public let pendingWithdrawal: String
        public let available: String
        public let withdrawable: String
        public let mainBalanceToDisplay: String?

        var totalPending: String {
            String((Int(pendingDeposit) ?? 0) - (Int(pendingWithdrawal) ?? 0))
        }

        static let zero = Balance(
            pending: "0",
            pendingDeposit: "0",
            pendingWithdrawal: "0",
            available: "0",
            withdrawable: "0",
            mainBalanceToDisplay: "0"
        )
    }

    // MARK: - Properties

    let balances: [String: Balance]

    // MARK: - Init

    init(balances: [String: Balance]) {
        self.balances = balances
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        balances = try container.decode([String: Balance].self)
    }

    // MARK: - Subscript

    subscript(currencyType: CurrencyType) -> Balance? {
        balances[currencyType.code]
    }
}
