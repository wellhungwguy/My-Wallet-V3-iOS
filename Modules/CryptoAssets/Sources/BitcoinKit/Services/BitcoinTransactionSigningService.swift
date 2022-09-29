// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BitcoinChainKit
import Combine
import FeatureTransactionDomain
import ToolKit
import WalletCore

public struct WalletCoreBitcoinSigningError: Error {

    private let walletCoreError: TW_Common_Proto_SigningError

    static func from(walletCoreError: TW_Common_Proto_SigningError) -> Self {
        Self(walletCoreError: walletCoreError)
    }
}

enum BitcoinTransactionSigningServiceError: Error {
    case invalidChangeAmount(Int64)
    case zeroFee
    case noUTXOs
    case signingError(WalletCoreBitcoinSigningError)
}

final class BitcoinTransactionSigningService: BitcoinChainTransactionSigningServiceAPI {

    func sign(
        candidate: NativeBitcoinTransactionCandidate
    ) -> AnyPublisher<NativeSignedBitcoinTransaction, BitcoinChainSigningError> {

        let keys = candidate.keys

        let toAddress = candidate.destinationAddress

        let changeAddress = candidate.changeAddress

        guard toAddress.isNotEmpty, changeAddress.isNotEmpty else {
            fatalError("Destination and change addresses should not be empty")
        }

        let walletCoreKeyPairs = keys
            .compactMap { keyPair -> WalletCoreKeyPair? in
                guard let key = WalletCore.PrivateKey(data: keyPair.privateKeyData) else {
                    return nil
                }
                return WalletCoreKeyPair(
                    privateKey: key,
                    xpriv: keyPair.xpriv,
                    xpub: keyPair.xpub.address
                )
            }

        let utxos = candidate.utxos
            .map { utxo -> BitcoinUnspentTransaction in
                BitcoinUnspentTransaction.with {
                    $0.outPoint.hash = Data.reverse(
                        hexString: utxo.hashBigEndian
                    )
                    // TODO: Check this:
                    // $0.outPoint.hash = Data(hex: utxo.hash)
                    $0.outPoint.index = UInt32(utxo.outputIndex)
                    $0.outPoint.sequence = UInt32.max
                    $0.script = Data(hex: utxo.script)
                    $0.amount = Int64(utxo.value.minorAmount)
                }
            }

        guard utxos.isNotEmpty else {
            let error = BitcoinTransactionSigningServiceError.noUTXOs
            return .failure(.signingError(error))
        }

        let amount = Int64(candidate.amount.minorAmount)

        let fee: Int64 = Int64(candidate.fees.minorAmount)

        guard fee > 0 else {
            let error = BitcoinTransactionSigningServiceError.zeroFee
            return .failure(.signingError(error))
        }

        let change = Int64(candidate.change.minorAmount)

        guard change >= 0 else {
            let error = BitcoinTransactionSigningServiceError.invalidChangeAmount(change)
            return .failure(.signingError(error))
        }

        let plan = BitcoinTransactionPlan.with {
            $0.amount = amount
            $0.fee = fee
            $0.change = change
            $0.utxos = utxos
        }

        let input = BitcoinSigningInput.with {
            $0.hashType = BitcoinScript.hashTypeForCoin(coinType: .bitcoin)
            $0.coinType = CoinType.bitcoin.rawValue
            $0.toAddress = toAddress
            $0.changeAddress = changeAddress
            $0.amount = amount
            $0.useMaxAmount = false
            $0.privateKey = walletCoreKeyPairs.map(\.privateKey).map(\.data)
            $0.plan = plan
        }

        let output: BitcoinSigningOutput = AnySigner.sign(
            input: input,
            coin: .bitcoin
        )

        guard output.error == .ok else {
            let error = BitcoinTransactionSigningServiceError.signingError(.from(walletCoreError: output.error))
            return .failure(.signingError(error))
        }

        guard candidate.fees.minorAmount == fee else {
            fatalError(
                "Candidate fees should always be in sync with the signed transaction"
            )
        }

        let encodedMsg = output.encoded.hex

        return .just(
            NativeSignedBitcoinTransaction(
                msgSize: output.encoded.count,
                txHash: output.transactionID,
                encodedMsg: encodedMsg,
                replayProtectionLockSecret: nil
            )
        )
    }
}
