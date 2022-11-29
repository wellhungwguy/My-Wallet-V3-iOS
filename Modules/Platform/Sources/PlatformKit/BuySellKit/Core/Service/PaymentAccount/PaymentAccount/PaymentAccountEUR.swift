// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import MoneyKit
import ToolKit

struct PaymentAccountEUR: PaymentAccountDescribing, Equatable {
    var fields: [PaymentAccountProperty.Field] {
        [
            .bankName(bankName),
            .bankCountry(bankCountry),
            .iban(iban.separatedWithSeparator(" ", stride: 4)),
            .bankCode(bankCode),
            .recipientName(recipientName)
        ]
    }

    static let currency: FiatCurrency = .EUR
    let identifier: String
    let state: PaymentAccountProperty.State
    let currency: FiatCurrency = Self.currency
    let bankName: String
    let bankCountry: String
    let iban: String
    let bankCode: String
    let recipientName: String

    init?(response: PlatformKit.PaymentAccount) {
        guard response.currency == Self.currency else {
            return nil
        }
        guard
            let bankName: String = response.agent.name,
            let bankCode: String = response.agent.code
        else { return nil }
        self.bankName = bankName
        self.bankCountry = response.agent.country ?? ""
        self.iban = response.address
        self.bankCode = bankCode
        self.recipientName = response.agent.recipient ?? ""
        self.identifier = response.id
        self.state = response.state
    }

    init(
        identifier: String,
        state: PaymentAccountProperty.State,
        bankName: String,
        bankCountry: String,
        iban: String,
        bankCode: String,
        recipientName: String
    ) {
        self.bankName = bankName
        self.bankCountry = bankCountry
        self.iban = iban
        self.bankCode = bankCode
        self.recipientName = recipientName
        self.identifier = identifier
        self.state = state
    }

    func with(bankCountry: String) -> PaymentAccountEUR {
        .init(
            identifier: identifier,
            state: state,
            bankName: bankName,
            bankCountry: bankCountry,
            iban: iban,
            bankCode: bankCode,
            recipientName: recipientName
        )
    }

    func with(recipientName: String) -> PaymentAccountEUR {
        .init(
            identifier: identifier,
            state: state,
            bankName: bankName,
            bankCountry: bankCountry,
            iban: iban,
            bankCode: bankCode,
            recipientName: recipientName
        )
    }
}
