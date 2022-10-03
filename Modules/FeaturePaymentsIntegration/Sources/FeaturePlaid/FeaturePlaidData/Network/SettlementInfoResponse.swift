// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Errors
import FeaturePlaidDomain
import ToolKit

public struct SettlementInfoResponse: Decodable {
    public let id: String
    public let partner: String
    public let state: String
    public let attributes: Attributes
    public let error: UX.Dialog?

    public struct Attributes: Decodable {
        public let settlementResponse: SettlementResponse

        public struct SettlementResponse: Decodable {
            public let settlementType: SettlementType
            public let reason: SettlementReasonType?
        }
    }
}
