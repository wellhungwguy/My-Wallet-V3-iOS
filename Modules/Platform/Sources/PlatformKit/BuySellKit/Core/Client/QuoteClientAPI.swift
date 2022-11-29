// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import Errors
import MoneyKit

public struct QuoteQueryRequest: Encodable {

    /// Profile for the quote
    let profile: String

    /// The trading pair for the quote
    let pair: String

    /// The fiat value represented in minor units
    let inputValue: String

    /// The payment method payload type used
    let paymentMethod: String?

    /// The payment method Id for the quote
    let paymentMethodId: String?

    init(from query: QuoteQuery) {
        self.profile = query.profile.rawValue
        self.pair = "\(query.sourceCurrency.code)-\(query.destinationCurrency.code)"
        self.inputValue = query.amount.minorString
        self.paymentMethod = query.paymentMethod?.rawValue
        self.paymentMethodId = query.paymentMethodId
    }
}

protocol QuoteClientAPI: AnyObject {

    /// Get a quote from a simple-buy order. In the future, it will support all sorts of order (buy, sell, swap)
    func getQuote(
        queryRequest: QuoteQueryRequest
    ) -> AnyPublisher<QuoteResponse, NabuNetworkError>
}
