// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation
import ToolKit

public struct ProductIneligibilityReason: NewTypeString {

    public static let eu5Sanction: Self = "EU_5_SANCTION" // SANCTIONS
    public static let tier1Required: Self = "TIER_1_REQUIRED" // INSUFFICIENT_TIER
    public static let tier2Required: Self = "TIER_2_REQUIRED" // INSUFFICIENT_TIER
    public static let tier1TradeLimit: Self = "TIER_1_TRADE_LIMIT" // INSUFFICIENT_TIER
    public static let featureNotAvailable: Self = "NOT_ELIGIBLE" // OTHER

    public var value: String

    public init(_ value: String) {
        self.value = value
    }
}

public struct ProductIneligibilityType: NewTypeString {

    public static let other: Self = "OTHER"
    public static let sanction: Self = "SANCTIONS"
    public static let insufficientTier: Self = "INSUFFICIENT_TIER"

    public var value: String

    public init(_ value: String) {
        self.value = value
    }
}

public struct ProductIneligibility: Codable, Hashable {

    /// type of ineligibility: sanctions, insufficient tier, other
    public let type: ProductIneligibilityType

    /// the ineligibility reason, for now only EU_5_SANCTION is supported
    public let reason: ProductIneligibilityReason

    /// message to be shown to the user
    public let message: String

    /// the url to show for learn more if any, this should come from the BE in the future
    public var learnMoreUrl: URL? {
        switch reason {
        case .eu5Sanction:
            return URL(string: "https://ec.europa.eu/commission/presscorner/detail/en/ip_22_2332")
        default:
            return nil
        }
    }

    public init(
        type: ProductIneligibilityType,
        message: String,
        reason: ProductIneligibilityReason
    ) {
        self.type = type
        self.message = message
        self.reason = reason
    }
}
