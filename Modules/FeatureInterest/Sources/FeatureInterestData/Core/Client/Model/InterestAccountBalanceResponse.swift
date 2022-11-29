// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import FeatureInterestDomain
import MoneyKit
import PlatformKit

public struct InterestAccountBalanceResponse: Decodable {

    public static let empty = InterestAccountBalanceResponse()

    // MARK: - Properties

    public let balances: [String: InterestAccountBalanceDetailsResponse]

    // MARK: - Init

    private init() {
        self.balances = [:]
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        self.balances = try container.decode([String: InterestAccountBalanceDetailsResponse].self)
    }

    // MARK: - Subscript

    public subscript(currency: CryptoCurrency) -> InterestAccountBalanceDetailsResponse? {
        balances[currency.code]
    }
}

extension InterestAccountBalances {
    init(_ response: InterestAccountBalanceResponse) {
        var balances: [String: InterestAccountBalanceDetails] = [:]
        response.balances.keys.forEach { key in
            balances[key] = InterestAccountBalanceDetails(
                response.balances[key]!,
                code: key
            )
        }
        self.init(balances: balances)
    }
}
