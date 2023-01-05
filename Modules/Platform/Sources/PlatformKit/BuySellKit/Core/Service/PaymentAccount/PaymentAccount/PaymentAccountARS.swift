// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Localization
import MoneyKit

struct PaymentAccountARS: PaymentAccountDescribing, Equatable {

    typealias L10n = LocalizationConstants.LineItem.Transactional

    var fields: [PaymentAccountProperty.Field] {
        [
            .bankName(bankName),
            .field(
                name: L10n.alias,
                value: label,
                help: L10n.aliasHelp,
                copy: true
            ),
            .field(
                name: L10n.accountHolder,
                value: name
            ),
            .field(
                name: L10n.CUIT,
                value: holderDocument
            ),
            .field(
                name: L10n.CBU,
                value: address
            ),
            .field(
                name: L10n.accountNumber,
                value: code
            ),
            .recipientName(recipientName)
        ]
    }

    static let currency: FiatCurrency = .ARS
    let identifier: String
    let state: PaymentAccountProperty.State
    let currency: FiatCurrency = Self.currency
    let name: String
    let bankName: String
    let code: String
    let recipientName: String
    let label: String
    let holderDocument: String
    let address: String

    init?(response: PaymentAccount) {
        guard response.currency == Self.currency else {
            return nil
        }
        guard
            let bankName: String = response.agent.bankName,
            let code: String = response.agent.code,
            let holderDocument: String = response.agent.holderDocument,
            let label: String = response.agent.label,
            let name: String = response.agent.name,
            let recipientName: String = response.agent.recipient
        else { return nil }
        self.bankName = bankName
        self.holderDocument = holderDocument
        self.label = label
        self.name = name
        self.recipientName = recipientName
        self.code = code
        self.address = response.address
        self.identifier = response.id
        self.state = response.state
    }
}
