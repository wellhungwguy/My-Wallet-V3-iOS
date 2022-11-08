// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import FeaturePlaidDomain
import ToolKit

public struct PaymentsDepositTermsResponse: Codable, Hashable {

    public let creditCurrency: String
    public let availableToTradeMinutesMin: Int
    public let availableToTradeMinutesMax: Int
    public let availableToTradeDisplayMode: PaymentsDepositTerms.DisplayMode
    public let availableToWithdrawMinutesMin: Int
    public let availableToWithdrawMinutesMax: Int
    public let availableToWithdrawDisplayMode: PaymentsDepositTerms.DisplayMode
    public let settlementType: SettlementType
    public let settlementReason: SettlementReasonType?
    public let withdrawalLockDays: Int?
}
