// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import MoneyKit
import PlatformKit

public struct RecurringBuy {

    public enum State: String {
        case active
        case inactive
        case uninitialised
    }

    public enum Frequency: String {
        case once = "ONE_TIME"
        case daily
        case weekly
        case biweekly = "BI_WEEKLY"
        case monthly
        case unknown
    }

    public let id: String
    public let state: State
    public let recurringBuyFrequency: Frequency
    public let nextPaymentDate: Date
    public let paymentMethodType: PaymentMethodPayloadType
    public let paymentMethodId: String?
    public let amount: MoneyValue
    public let asset: CurrencyType
    public let createDate: Date

    public init(
        id: String, state: State,
        recurringBuyFrequency: Frequency,
        nextPaymentDate: Date,
        paymentMethodType: PaymentMethodPayloadType,
        paymentMethodId: String?,
        amount: MoneyValue,
        asset: CurrencyType,
        createDate: Date
    ) {
        self.id = id
        self.state = state
        self.recurringBuyFrequency = recurringBuyFrequency
        self.nextPaymentDate = nextPaymentDate
        self.paymentMethodType = paymentMethodType
        self.paymentMethodId = paymentMethodId
        self.amount = amount
        self.asset = asset
        self.createDate = createDate
    }
}
