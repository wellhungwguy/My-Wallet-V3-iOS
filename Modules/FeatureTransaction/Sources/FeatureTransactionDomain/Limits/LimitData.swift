// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import MoneyKit
import PlatformKit

public struct TradeLimit {

    public let limit: MoneyValue
    public let available: MoneyValue
    public let used: MoneyValue

    public init(
        limit: MoneyValue,
        available: MoneyValue,
        used: MoneyValue
    ) {
        self.limit = limit
        self.available = available
        self.used = used
    }
}

public struct PeriodicLimit: Decodable, Equatable {

    public let limit: MoneyValue
    public let effective: Bool?
}

public struct PeriodicLimits: Decodable, Equatable {

    public let available: MoneyValue
    public let daily: PeriodicLimit?
    public let monthly: PeriodicLimit?
    public let yearly: PeriodicLimit?
}

public struct EffectiveLimit: Equatable {

    public enum TimeFrame: Equatable {
        case single // a single trade
        case daily, monthly, yearly
    }

    public let timeframe: TimeFrame
    public let value: MoneyValue
}

public struct SuggestedLimitsUpgrade: Decodable, Equatable {

    public let requiredTier: KYC.Tier
    public let available: MoneyValue?
    public let daily: PeriodicLimit?
    public let monthly: PeriodicLimit?
    public let yearly: PeriodicLimit?
}

// MARK: - Currency Conversion

extension PeriodicLimit {

    public static func max(
        _ x: PeriodicLimit,
        _ y: PeriodicLimit
    ) throws -> PeriodicLimit {
        let value: MoneyValue = try .max(x.limit, y.limit)
        let effective: Bool? = try x.limit > y.limit ? x.effective : y.effective
        return .init(
            limit: value,
            effective: effective
        )
    }

    func convert(using exchangeRate: MoneyValue) -> PeriodicLimit {
        PeriodicLimit(
            limit: limit.convert(using: exchangeRate),
            effective: effective
        )
    }
}

extension PeriodicLimits {

    func convert(using exchangeRate: MoneyValue) -> PeriodicLimits {
        PeriodicLimits(
            available: available.convert(using: exchangeRate),
            daily: daily?.convert(using: exchangeRate),
            monthly: monthly?.convert(using: exchangeRate),
            yearly: yearly?.convert(using: exchangeRate)
        )
    }
}

extension EffectiveLimit {

    public static func min(
        _ x: EffectiveLimit?,
        _ y: EffectiveLimit?
    ) throws -> EffectiveLimit? {
        guard let x, let y else {
            return x ?? y
        }
        let value: MoneyValue = try .min(x.value, y.value)
        let timeframe: TimeFrame = try x.value < y.value ? x.timeframe : y.timeframe
        return .init(
            timeframe: timeframe,
            value: value
        )
    }

    public static func max(
        _ x: EffectiveLimit?,
        _ y: EffectiveLimit?
    ) throws -> EffectiveLimit? {
        guard let x, let y else {
            return x ?? y
        }
        let value: MoneyValue = try .max(x.value, y.value)
        let timeframe: TimeFrame = try x.value > y.value ? x.timeframe : y.timeframe
        return .init(
            timeframe: timeframe,
            value: value
        )
    }

    public func convert(using exchangeRate: MoneyValue) -> EffectiveLimit {
        EffectiveLimit(
            timeframe: timeframe,
            value: value.convert(using: exchangeRate)
        )
    }
}

extension SuggestedLimitsUpgrade {

    public func convert(using exchangeRate: MoneyValue) -> SuggestedLimitsUpgrade {
        SuggestedLimitsUpgrade(
            requiredTier: requiredTier,
            available: available?.convert(using: exchangeRate),
            daily: daily?.convert(using: exchangeRate),
            monthly: monthly?.convert(using: exchangeRate),
            yearly: yearly?.convert(using: exchangeRate)
        )
    }
}
