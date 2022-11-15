// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation
import PlatformKit

public struct EligibleAndNextPaymentRecurringBuy: Equatable, Decodable, Identifiable {

    public var id: String {
        frequency.rawValue + eligiblePaymentMethodTypes.map(\.rawValue).joined() + nextPaymentDate.description
    }

    public let frequency: RecurringBuy.Frequency
    public let nextPaymentDate: Date
    public let eligiblePaymentMethodTypes: [PaymentMethodPayloadType]

    public init?(
        frequency: String,
        nextPayment: String,
        eligiblePaymentMethodTypes: [String]
    ) {
        guard let frequency: RecurringBuy.Frequency = .init(rawValue: frequency) else { return nil }
        self.frequency = frequency
        self.nextPaymentDate = DateFormatter.iso8601Format.date(from: nextPayment) ?? Date()
        self.eligiblePaymentMethodTypes = eligiblePaymentMethodTypes.compactMap(PaymentMethodPayloadType.init(rawValue:))
    }

    init(
        frequency: RecurringBuy.Frequency,
        nextPaymentDate: Date,
        eligiblePaymentMethodTypes: [PaymentMethodPayloadType]
    ) {
        self.frequency = frequency
        self.nextPaymentDate = nextPaymentDate
        self.eligiblePaymentMethodTypes = eligiblePaymentMethodTypes
    }
}

extension EligibleAndNextPaymentRecurringBuy {
    public static let oneTime = EligibleAndNextPaymentRecurringBuy(
        frequency: .once,
        nextPaymentDate: Date(),
        eligiblePaymentMethodTypes: PaymentMethodPayloadType.allCases
    )
}
