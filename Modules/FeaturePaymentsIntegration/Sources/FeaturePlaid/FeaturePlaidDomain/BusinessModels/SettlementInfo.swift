// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Errors
import ToolKit

public struct SettlementInfo {
    public let id: String
    public let partner: String
    public let state: String
    public let error: UX.Dialog?
    public let settlement: Settlement

    public init(
        id: String,
        partner: String,
        state: String,
        error: UX.Dialog? = nil,
        settlement: SettlementInfo.Settlement
    ) {
        self.id = id
        self.partner = partner
        self.state = state
        self.error = error
        self.settlement = settlement
    }
}

extension SettlementInfo {
    public struct Settlement {
        public let settlementType: SettlementType
        public let reason: SettlementReasonType?

        public init(
            settlementType: SettlementType,
            reason: SettlementReasonType?
        ) {
            self.settlementType = settlementType
            self.reason = reason
        }
    }
}

public struct SettlementType: NewTypeString {
    public var value: String
    public init(_ value: String) { self.value = value }

    public static let instant: Self = "INSTANT"
    public static let regular: Self = "REGULAR"
    public static let unavailable: Self = "UNAVAILABLE"
}

public struct SettlementReasonType: NewTypeString {
    public var value: String
    public init(_ value: String) { self.value = value }

    public static let requiresUpdate: Self = "REQUIRES_UPDATE"
    public static let insufficientBalance: Self = "INSUFFICIENT_BALANCE"
    public static let staleBalance: Self = "STALE_BALANCE"
    public static let generic: Self = "GENERIC"
}
