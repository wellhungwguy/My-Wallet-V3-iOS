// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BigInt
import ERC20Kit
import EthereumKit
import Localization
import MoneyKit
import PlatformKit
import PlatformUIKit

extension ERC20ActivityDetailsViewModel {

    init(details: EthereumActivityItemEventDetails, price: FiatValue?, feePrice: FiatValue?) {
        confirmation = Confirmation(
            needConfirmation: details.confirmation.needConfirmation,
            title: "\(details.confirmation.confirmations) \(LocalizedString.of) \(details.confirmation.requiredConfirmations) \(LocalizedString.confirmations)",
            factor: details.confirmation.factor,
            statusBadge: details.confirmation.status.statusBadge
        )
        dateCreated = DateFormatter.elegantDateFormatter.string(from: details.createdAt)

        let gas = ERC20ContractGasActivityModel(details: details)
        amounts = ERC20ActivityDetailsViewModel.amounts(details: details, gas: gas, price: price, feePrice: feePrice)

        to = gas?.to?.publicKey
        from = details.from.publicKey

        fee = "\(amounts.fee.cryptoAmount) / \(amounts.fee.value)"
    }

    private static func amounts(
        details: EthereumActivityItemEventDetails,
        gas: ERC20ContractGasActivityModel?,
        price: FiatValue?,
        feePrice: FiatValue?
    ) -> Amounts {
        func value(cryptoValue: CryptoValue, price: FiatValue?) -> Amounts.Value {
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
            gasFor = value(cryptoValue: gasCryptoValue, price: price)
        }

        return Amounts(
            fee: value(cryptoValue: details.fee, price: feePrice),
            gasFor: gasFor
        )
    }
}
