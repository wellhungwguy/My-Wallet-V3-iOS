// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BitcoinChainKit
import Combine
import Foundation
import ToolKit
import WalletCore
import YenomBitcoinKit

enum BchSigningServiceError: Error {
    case invalidDestinationAddress
    case invalidChangeAddress
    case signingFailure
}

protocol BchSigningServiceAPI {

    func sign(input: BchSigningInput) -> Result<BchSigningOutput, BchSigningServiceError>
}

final class BchSigningService: BchSigningServiceAPI {

    func sign(
        input: BchSigningInput
    ) -> Result<BchSigningOutput, BchSigningServiceError> {
        YenomBitcoinKit.RIPEMD160.hashFunction = { data in
            WalletCore.Hash.ripemd(data: data)
        }

        guard let toAddress = cashAddr(string: input.toAddress) else {
            return .failure(.invalidDestinationAddress)
        }

        guard let changeAddress = cashAddr(string: input.changeAddress) else {
            return .failure(.invalidChangeAddress)
        }

        let unspentTransactions: [UnspentTransaction] = input.spendableOutputs.map(\.unspentTransaction)
        let plan = YenomBitcoinKit.TransactionPlan(
            unspentTransactions: unspentTransactions,
            amount: input.amount,
            fee: 0,
            change: input.change
        )

        let transaction = YenomBitcoinKit.TransactionBuilder.build(
            from: plan,
            toAddress: toAddress,
            changeAddress: changeAddress,
            dustMixing: input.dust?.dustMixing
        )
        let signer = TransactionSigner(
            unspentTransactions: unspentTransactions,
            transaction: transaction,
            sighashHelper: BCHSignatureHashHelper(hashType: .ALL)
        )

        let privateKeys = input.privateKeys
            .map(YenomBitcoinKit.PrivateKey.from(data:))

        return signer.sign(with: privateKeys)
            .replaceError(with: BchSigningServiceError.signingFailure)
            .map { signed in
                BchSigningOutput(
                    data: signed.serialized(),
                    transactionHash: signed.txHash.hex,
                    replayProtectionLockSecret: input.dust?.lockSecret
                )
            }
    }

    private func cashAddr(string: String) -> YenomBitcoinKit.BitcoinAddress? {
        (try? YenomBitcoinKit.BitcoinAddress(cashaddr: string))
            ?? (try? YenomBitcoinKit.BitcoinAddress(cashaddr: "bitcoincash:" + string))
    }
}

extension YenomBitcoinKit.PrivateKey {

    fileprivate static func from(data: Data) -> Self {
        Self(data: data)
    }
}

extension YenomBitcoinKit.TransactionSigner {

    fileprivate func sign(
        with privateKeys: [YenomBitcoinKit.PrivateKey]
    ) -> Result<YenomBitcoinKit.Transaction, Error> {
        Result { try sign(with: privateKeys) }
    }
}

extension DustMixing {

    fileprivate var dustMixing: YenomBitcoinKit.DustMixing {
        YenomBitcoinKit.DustMixing(
            unspentTransaction: unspentOutput.unspentTransaction,
            amount: amount,
            outputScript: outputScript
        )
    }
}

extension UnspentOutput {
    fileprivate var unspentTransaction: UnspentTransaction {
        UnspentTransaction(
            output: TransactionOutput(value: UInt64(value.minorAmount), lockingScript: Data(hex: script)),
            outpoint: TransactionOutPoint(hash: Data(hex: hash), index: UInt32(outputIndex))
        )
    }
}
