// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BigInt
import ERC20Kit
import EthereumKit
import Localization
import MoneyKit
import PlatformKit
import PlatformUIKit

extension ERC20ActivityDetailsViewModel {

    init(details: EVMHistoricalTransaction, price: FiatValue?, feePrice: FiatValue?) {
        let title = "\(details.confirmation.confirmations) \(LocalizedString.of) \(details.confirmation.requiredConfirmations) \(LocalizedString.confirmations)"
        confirmation = Confirmation(
            needConfirmation: details.confirmation.needConfirmation,
            title: title,
            factor: details.confirmation.factor,
            statusBadge: details.confirmation.status.statusBadge
        )
        dateCreated = DateFormatter.elegantDateFormatter.string(from: details.createdAt)
        amounts = Self.amounts(details: details, price: price, feePrice: feePrice)
        to = details.to.publicKey
        from = details.from.publicKey
        fee = "\(amounts.fee.cryptoAmount) / \(amounts.fee.value)"
    }

    private static func amounts(
        details: EVMHistoricalTransaction,
        price: FiatValue?,
        feePrice: FiatValue?
    ) -> Amounts {
        func value(cryptoValue: CryptoValue, price: FiatValue?) -> Amounts.Value {
            let cryptoAmount = cryptoValue.displayString
            let value: String
            if let price {
                value = cryptoValue.convert(using: price).displayString
            } else {
                value = ""
            }
            return Amounts.Value(cryptoAmount: cryptoAmount, value: value)
        }

        return Amounts(
            fee: value(cryptoValue: details.fee, price: feePrice),
            gasFor: value(cryptoValue: details.amount, price: price)
        )
    }
}
