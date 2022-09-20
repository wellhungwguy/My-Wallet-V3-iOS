// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BigInt
import ERC20Kit
import EthereumKit
import Localization
import MoneyKit
import PlatformKit
import PlatformUIKit

extension EthereumActivityDetailsViewModel {

    init(details: EVMHistoricalTransaction, price: FiatValue?) {
        let title = "\(details.confirmation.confirmations) \(LocalizedString.of) \(details.confirmation.requiredConfirmations) \(LocalizedString.confirmations)"
        confirmation = Confirmation(
            needConfirmation: details.confirmation.needConfirmation,
            title: title,
            factor: details.confirmation.factor,
            statusBadge: details.confirmation.status.statusBadge
        )
        dateCreated = DateFormatter.elegantDateFormatter.string(from: details.createdAt)
        amounts = Self.amounts(details: details, price: price)
        fee = "\(amounts.fee.cryptoAmount) / \(amounts.fee.value)"
        to = details.to.publicKey
        from = details.from.publicKey
        note = ""
    }

    private static func amounts(
        details: EVMHistoricalTransaction,
        price: FiatValue?
    ) -> Amounts {
        func value(cryptoValue: CryptoValue) -> Amounts.Value {
            let cryptoAmount = cryptoValue.displayString
            let value: String = price
                .flatMap { price -> String in
                    cryptoValue.convert(using: price).displayString
                } ?? ""
            return Amounts.Value(cryptoAmount: cryptoAmount, value: value)
        }

        return Amounts(
            fee: value(cryptoValue: details.fee),
            trade: value(cryptoValue: details.amount),
            gasFor: nil,
            isGas: false
        )
    }
}
