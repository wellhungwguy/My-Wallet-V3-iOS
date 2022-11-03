// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import MoneyKit

public struct Beneficiary {
    public enum AccountType: Equatable {
        case funds
        case linkedBank
    }

    public let type: AccountType
    public let currency: FiatCurrency
    public let name: String
    public let identifier: String
    public let account: String
    public var limit: FiatValue?
    public let icon: URL?
    public let isBankAccount: Bool?
    public let isBankTransferAccount: Bool?

    init?(response: BeneficiaryResponse, limit: FiatValue?) {
        type = .funds
        identifier = response.id
        name = response.name
        var address = response.address
        address.removeAll { $0 == "*" }
        account = address
        self.limit = limit
        guard let currency = FiatCurrency(code: response.currency) else {
            return nil
        }
        self.currency = currency
        icon = nil
        isBankAccount = nil
        isBankTransferAccount = nil
    }

    init(linkedBankData: LinkedBankData) {
        identifier = linkedBankData.identifier
        currency = linkedBankData.currency
        type = .linkedBank
        let bankName = linkedBankData.account?.bankName ?? ""
        let accountType = linkedBankData.account?.type.title ?? ""
        let accountNumber = linkedBankData.account?.number ?? ""
        name = "\(bankName)"
        account = "\(accountType) \(accountNumber)"
        limit = nil
        icon = linkedBankData.icon
        isBankAccount = linkedBankData.isBankAccount
        isBankTransferAccount = linkedBankData.isBankTransferAccount
    }
}

extension Beneficiary: Equatable {
    public static func == (lhs: Beneficiary, rhs: Beneficiary) -> Bool {
        lhs.identifier == rhs.identifier
    }
}
