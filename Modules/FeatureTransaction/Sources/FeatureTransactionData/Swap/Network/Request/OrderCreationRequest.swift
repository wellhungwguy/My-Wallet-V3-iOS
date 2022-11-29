// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import FeatureTransactionDomain
import MoneyKit
import PlatformKit

struct OrderCreationRequest: Encodable {
    let direction: OrderDirection
    let quoteId: String
    let volume: MoneyValue
    // Only for `ON_CHAIN` & `TO_USERKEY` directions
    let destinationAddress: String?
    // Only for `ON_CHAIN` & `FROM_USERKEY` directions
    let refundAddress: String?
    // Only for selling
    let ccy: String?

    private enum CodingKeys: CodingKey {
        case direction
        case quoteId
        case volume
        case destinationAddress
        case refundAddress
        case ccy
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        let value = volume.minorString
        try container.encode(direction, forKey: .direction)
        try container.encode(value, forKey: .volume)
        try container.encode(quoteId, forKey: .quoteId)
        try container.encodeIfPresent(destinationAddress, forKey: .destinationAddress)
        try container.encodeIfPresent(refundAddress, forKey: .refundAddress)
        try container.encodeIfPresent(ccy, forKey: .ccy)
    }
}

struct OrderUpdateRequest: Encodable {
    let action: String

    init(success: Bool) {
        self.action = success ? "DEPOSIT_SENT" : "CANCEL"
    }
}
