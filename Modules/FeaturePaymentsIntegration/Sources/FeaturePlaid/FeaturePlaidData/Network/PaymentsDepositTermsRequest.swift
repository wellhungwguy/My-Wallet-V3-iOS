// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import MoneyKit

public struct PaymentsDepositTermsRequest: Encodable {

    public let amount: MoneyValue
    public let paymentMethodId: String
    public let product = "WALLET"
    public let purpose = "DEPOSIT"

    public init(
        amount: MoneyValue,
        paymentMethodId: String
    ) {
        self.amount = amount
        self.paymentMethodId = paymentMethodId
    }
}
