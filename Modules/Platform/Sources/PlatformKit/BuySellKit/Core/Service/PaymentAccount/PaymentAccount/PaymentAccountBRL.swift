// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Localization
import MoneyKit

struct PaymentAccountBRL: PaymentAccountDescribing, Equatable {
    var fields: [PaymentAccountProperty.Field] {
        [
            .bankName(bankName),
            .recipientName(recipientName),
            .bankCode(bankCode),
            .accountNumber(accountNumber),
            .routingNumber(routingNumber)
        ]
    }

    static let currency: FiatCurrency = .BRL
    let identifier: String
    let state: PaymentAccountProperty.State
    let currency: FiatCurrency = Self.currency
    let bankName: String
    let bankCountry: String
    let bankCode: String
    let accountNumber: String
    let routingNumber: String
    let recipientName: String

    init?(response: PaymentAccount) {
        guard response.currency == Self.currency else { return nil }
        guard
            let accountNumber: String = response.agent.account,
            let recipientName: String = response.agent.recipient,
            let routingNumber: String = response.agent.routingNumber,
            let name: String = response.agent.name,
            let country: String = response.agent.country,
            let code: String = response.agent.code
        else { return nil }
        self.routingNumber = routingNumber
        self.accountNumber = accountNumber
        self.recipientName = recipientName
        bankCountry = country
        bankName = name
        bankCode = code
        identifier = response.id
        state = response.state
    }
}
