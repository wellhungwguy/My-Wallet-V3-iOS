// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import MoneyKit
import PlatformKit

public struct InterestAccountBalances: Equatable {

    public static let empty = InterestAccountBalances()

    // MARK: - Properties

    public let balances: [String: InterestAccountBalanceDetails]

    // MARK: - Init

    public init(balances: [String: InterestAccountBalanceDetails]) {
        self.balances = balances
    }

    private init() {
        self.balances = [:]
    }

    // MARK: - Subscript

    public subscript(currency: CryptoCurrency) -> InterestAccountBalanceDetails? {
        balances[currency.code]
    }
}
