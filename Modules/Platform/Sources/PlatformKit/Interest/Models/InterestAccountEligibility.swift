// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import MoneyKit

public struct InterestAccountEligibility: Equatable {

    public let currencyType: CurrencyType
    public let isEligible: Bool
    public let ineligibilityReason: InterestAccountIneligibilityReason

    public init(
        currencyType: CurrencyType,
        isEligible: Bool,
        ineligibilityReason: InterestAccountIneligibilityReason
    ) {
        self.currencyType = currencyType
        self.isEligible = isEligible
        self.ineligibilityReason = ineligibilityReason
    }

    public init(
        currencyType: CurrencyType,
        interestEligibility: InterestEligibility
    ) {
        self.currencyType = currencyType
        self.isEligible = interestEligibility.isEligible
        self.ineligibilityReason = .init(ineligibilityReason: interestEligibility.ineligibilityReason)
    }

    public static func notEligible(currencyType: CurrencyType) -> InterestAccountEligibility {
        .init(
            currencyType: currencyType,
            isEligible: false,
            ineligibilityReason: .other
        )
    }
}

public enum InterestAccountIneligibilityReason: String {
    case unsupportedRegion = "UNSUPPORTED_REGION"
    case tierTooLow = "TIER_TOO_LOW"
    case invalidAddress = "INVALID_ADDRESS"
    case eligible = "NONE"
    case other = "OTHER"

    public init(ineligibilityReason: String?) {
        self = .init(rawValue: ineligibilityReason ?? "NONE") ?? .eligible
    }

    public var isEligible: Bool {
        self == .eligible
    }
}
