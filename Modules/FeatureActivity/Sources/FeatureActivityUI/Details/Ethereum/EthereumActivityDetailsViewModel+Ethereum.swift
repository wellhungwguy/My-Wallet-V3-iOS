// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BigInt
import ERC20Kit
import EthereumKit
import Localization
import MoneyKit
import PlatformKit
import PlatformUIKit

extension EthereumActivityDetailsViewModel {

    init(details: EthereumActivityItemEventDetails, price: FiatValue?, note: String? = nil) {
        confirmation = Confirmation(
            needConfirmation: details.confirmation.needConfirmation,
            title: "\(details.confirmation.confirmations) \(LocalizedString.of) \(details.confirmation.requiredConfirmations) \(LocalizedString.confirmations)",
            factor: details.confirmation.factor,
            statusBadge: details.confirmation.status.statusBadge
        )
        dateCreated = DateFormatter.elegantDateFormatter.string(from: details.createdAt)
        to = details.to.publicKey
        from = details.from.publicKey

        let gas = ERC20ContractGasActivityModel(details: details)
        amounts = Self.amounts(details: details, gas: gas, price: price)
        fee = "\(amounts.fee.cryptoAmount) / \(amounts.fee.value)"

        self.note = note ?? ""
    }

    private static func amounts(
        details: EthereumActivityItemEventDetails,
        gas: ERC20ContractGasActivityModel?,
        price: FiatValue?
    ) -> Amounts {

        func value(cryptoValue: CryptoValue) -> Amounts.Value {
            let cryptoAmount = cryptoValue.displayString
            let value: String
            if let price = price {
                value = cryptoValue.convert(using: price).displayString
            } else {
                value = ""
            }
            return Amounts.Value(cryptoAmount: cryptoAmount, value: value)
        }

        var gasFor: Amounts.Value?

        if let gasCryptoValue = gas?.cryptoValue {
            gasFor = value(cryptoValue: gasCryptoValue)
        }

        return Amounts(
            fee: value(cryptoValue: details.fee),
            trade: value(cryptoValue: details.amount),
            gasFor: gasFor,
            isGas: gas != nil
        )
    }
}
