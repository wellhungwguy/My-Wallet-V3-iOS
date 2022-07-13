// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation
import ToolKit

public struct ProductIdentifier: NewTypeString {
    public static let buy: Self = "BUY"
    public static let sell: Self = "SELL"
    public static let swap: Self = "SWAP"
    public static let trade: Self = "TRADE"
    public static let depositFiat: Self = "DEPOSIT_FIAT"
    public static let depositCrypto: Self = "DEPOSIT_CRYPTO"
    public static let depositInterest: Self = "DEPOSIT_INTEREST"
    public static let withdrawFiat: Self = "WITHDRAW_FIAT"
    public static let withdrawCrypto: Self = "WITHDRAW_CRYPTO"

    public var value: String

    public init(_ value: String) {
        self.value = value
    }
}

public struct ProductSuggestedUpgrade: Hashable, Codable {

    public let requiredTier: Int

    public init(requiredTier: Int) {
        self.requiredTier = requiredTier
    }
}

public struct ProductValue: Hashable, Identifiable, Codable {

    public let id: ProductIdentifier
    public let enabled: Bool
    public let maxOrdersCap: Int?
    public let maxOrdersLeft: Int?
    public let suggestedUpgrade: ProductSuggestedUpgrade?
    public let reasonNotEligible: ProductIneligibility?

    public init(
        id: ProductIdentifier,
        enabled: Bool,
        maxOrdersCap: Int? = nil,
        maxOrdersLeft: Int? = nil,
        suggestedUpgrade: ProductSuggestedUpgrade? = nil,
        reasonNotEligible: ProductIneligibility? = nil
    ) {
        self.id = id
        self.enabled = enabled
        self.maxOrdersCap = maxOrdersCap
        self.maxOrdersLeft = maxOrdersLeft
        self.suggestedUpgrade = suggestedUpgrade
        self.reasonNotEligible = reasonNotEligible
    }
}
