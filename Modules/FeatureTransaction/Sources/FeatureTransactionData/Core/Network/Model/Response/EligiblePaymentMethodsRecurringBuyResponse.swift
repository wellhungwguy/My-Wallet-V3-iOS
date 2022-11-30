// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import FeatureTransactionDomain
import Foundation

struct EligiblePaymentMethodsRecurringBuyResponse: Decodable {
    let nextPayments: [EligibleAndNextPaymentRecurringBuyResponse]
}

struct EligibleAndNextPaymentRecurringBuyResponse: Decodable {
    let period: String
    let nextPayment: String
    let eligibleMethods: [String]
}

extension EligibleAndNextPaymentRecurringBuy {
    init?(response: EligibleAndNextPaymentRecurringBuyResponse) {
        guard let value: EligibleAndNextPaymentRecurringBuy = .init(
            frequency: response.period,
            nextPayment: response.nextPayment,
            eligiblePaymentMethodTypes: response.eligibleMethods
        ) else { return nil }
        self = value
    }
}
