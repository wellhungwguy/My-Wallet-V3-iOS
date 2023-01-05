// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import MoneyKit
import PlatformKit

struct InterestEligibilityResponse: Decodable, Equatable {

    // MARK: - Properties

    let interestEligibilities: [String: InterestEligibility]

    // MARK: - Init

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        do {
            self.interestEligibilities = try container.decode([String: InterestEligibility].self)
        } catch {
            self.interestEligibilities = [:]
        }
    }

    // MARK: - Subscript

    subscript(currencyType: CurrencyType) -> InterestEligibility? {
        interestEligibilities[currencyType.code]
    }
}
