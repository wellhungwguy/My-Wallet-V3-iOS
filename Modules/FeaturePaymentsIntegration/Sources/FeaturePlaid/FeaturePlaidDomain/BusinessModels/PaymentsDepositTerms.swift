// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import ToolKit

public struct PaymentsDepositTerms: Codable, Hashable {

    public let creditCurrency: String
    public let availableToTradeMinutesMin: Int
    public let availableToTradeMinutesMax: Int
    public let availableToTradeDisplayMode: DisplayMode
    public let availableToWithdrawMinutesMin: Int
    public let availableToWithdrawMinutesMax: Int
    public let availableToWithdrawDisplayMode: DisplayMode
    public let settlementType: SettlementType
    public let settlementReason: SettlementReasonType?
    public let withdrawalLockDays: Int?

    public init(
        creditCurrency: String,
        availableToTradeMinutesMin: Int,
        availableToTradeMinutesMax: Int,
        availableToTradeDisplayMode: DisplayMode,
        availableToWithdrawMinutesMin: Int,
        availableToWithdrawMinutesMax: Int,
        availableToWithdrawDisplayMode: DisplayMode,
        settlementType: SettlementType,
        settlementReason: SettlementReasonType?,
        withdrawalLockDays: Int?
    ) {
        self.creditCurrency = creditCurrency
        self.availableToTradeMinutesMin = availableToTradeMinutesMin
        self.availableToTradeMinutesMax = availableToTradeMinutesMax
        self.availableToTradeDisplayMode = availableToTradeDisplayMode
        self.availableToWithdrawMinutesMin = availableToWithdrawMinutesMin
        self.availableToWithdrawMinutesMax = availableToWithdrawMinutesMax
        self.availableToWithdrawDisplayMode = availableToWithdrawDisplayMode
        self.settlementType = settlementType
        self.settlementReason = settlementReason
        self.withdrawalLockDays = withdrawalLockDays
    }
}

extension PaymentsDepositTerms {
    public struct DisplayMode: NewTypeString {

        public private(set) var value: String

        public init(_ value: String) { self.value = value }

        public static let immediately: Self = "IMMEDIATELY"
        public static let dayRange: Self = "DAY_RANGE"
        public static let maxDay: Self = "MAX_DAY"
        public static let minuteRange: Self = "MINUTE_RANGE"
        public static let maxMinute: Self = "MAX_MINUTE"
        public static let none: Self = "NONE"
    }
}
