// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import DIKit
import Errors
import FeatureTransactionDomain
import MoneyKit
import PlatformKit
import ToolKit
import WalletCore

enum BitcoinTransactionBuildingServiceError: Error {
    case invalidAddress
    case unsupportedAddressFormat
    case networkError(NetworkError)
    case coinSelection(CoinSelectionError)
}

protocol BitcoinChainTransactionBuildingServiceAPI {

    // swiftlint:disable function_parameter_count
    func buildCandidate(
        keys: [WalletKeyPair],
        unspentOutputs: [UnspentOutput],
        changeAddress: String,
        destinationAddress: String,
        amount: CryptoValue,
        feePerByte: CryptoValue
    ) -> AnyPublisher<
        NativeBitcoinTransactionCandidate,
        BitcoinTransactionBuildingServiceError
    >
}

typealias SelectCoins =
    (CoinSelectionInputs) -> AnyPublisher<SpendableUnspentOutputs, CoinSelectionError>

typealias SelectAllCoins =
    ([UnspentOutput], BigUInt, BitcoinScriptType)
        ->
        AnyPublisher<SpendableUnspentOutputs, CoinSelectionError>

final class BitcoinChainTransactionBuildingService: BitcoinChainTransactionBuildingServiceAPI {

    // MARK: - Properties

    private let unspentOutputRepository: UnspentOutputRepositoryAPI
    private let coinSelection: CoinSelector
    private let selectCoins: SelectCoins
    private let selectAllCoins: SelectAllCoins
    private let coin: BitcoinChainCoin

    // MARK: - Setup

    init(
        unspentOutputRepository: UnspentOutputRepositoryAPI,
        coinSelection: CoinSelector,
        coin: BitcoinChainCoin
    ) {
        self.unspentOutputRepository = unspentOutputRepository
        self.coinSelection = coinSelection
        self.coin = coin
        self.selectCoins = { [coinSelection] selectionInputs in
            coinSelection.select(inputs: selectionInputs)
                .publisher
                .eraseToAnyPublisher()
        }
        self.selectAllCoins = { [coinSelection] coins, feePerByte, singleOutputType in
            coinSelection.select(
                all: coins,
                feePerByte: feePerByte,
                singleOutputType: singleOutputType
            )
            .publisher
            .eraseToAnyPublisher()
        }
    }

    // MARK: - API

    // swiftlint:disable function_parameter_count
    func buildCandidate(
        keys: [WalletKeyPair],
        unspentOutputs: [UnspentOutput],
        changeAddress: String,
        destinationAddress: String,
        amount: CryptoValue,
        feePerByte: CryptoValue
    ) -> AnyPublisher<
        NativeBitcoinTransactionCandidate,
        BitcoinTransactionBuildingServiceError
    > {
        let currency = coin.cryptoCurrency

        guard amount.currency == currency else {
            fatalError("Only \(currency.name) is supported by this class")
        }

        guard destinationAddress.isNotEmpty, changeAddress.isNotEmpty else {
            fatalError("Destination and change addresses should not be empty")
        }

        return scriptType(for: destinationAddress, coin: coin)
            .zip(scriptType(for: changeAddress, coin: coin))
            .flatMap { [selectCoins, selectAllCoins] targetScriptType, changeScriptType
                ->
                AnyPublisher<
                    NativeBitcoinTransactionCandidate,
                    BitcoinTransactionBuildingServiceError
                >
                in

                let feePerByte = BigUInt(feePerByte.minorAmount)

                let inputs = CoinSelectionInputs(
                    target: .init(value: BigUInt(amount.minorAmount), scriptType: targetScriptType),
                    feePerByte: feePerByte,
                    unspentOutputs: unspentOutputs,
                    sortingStrategy: AscentDrawSortingStrategy(),
                    changeOutputType: changeScriptType
                )

                // TODO:
                // * Test supported change types
                // * Test supported script types

                let select = selectCoins(inputs)
                    .optional()
                    .replaceError(with: nil)
                let selectAll = selectAllCoins(unspentOutputs, feePerByte, targetScriptType)
                    .optional()
                    .replaceError(with: nil)
                return select.zip(selectAll)
                    .map { selectedOutputs, allOutputs
                        -> NativeBitcoinTransactionCandidate in
                        let available = CryptoValue.create(
                            minor: BigInt(allOutputs?.amount ?? 0),
                            currency: currency
                        )
                        let feeForMaxAvailable = CryptoValue.create(
                            minor: BigInt(allOutputs?.absoluteFee ?? 0),
                            currency: currency
                        )
                        let fees = CryptoValue.create(
                            minor: BigInt(selectedOutputs?.absoluteFee ?? 0),
                            currency: currency
                        )
                        let change = CryptoValue.create(
                            minor: BigInt(selectedOutputs?.change ?? 0),
                            currency: currency
                        )
                        let candidate = NativeBitcoinTransactionCandidate(
                            keys: keys,
                            changeAddress: changeAddress,
                            destinationAddress: destinationAddress,
                            amount: amount,
                            fees: fees,
                            change: change,
                            utxos: selectedOutputs?.spendableOutputs ?? [],
                            maxValue: .init(
                                available: available,
                                feeForMaxAvailable: feeForMaxAvailable
                            )
                        )
                        return candidate
                    }
                    .setFailureType(to: BitcoinTransactionBuildingServiceError.self)
                    .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }
}

private func scriptType(
    for targetAddress: String,
    coin: BitcoinChainCoin
) -> AnyPublisher<BitcoinScriptType, BitcoinTransactionBuildingServiceError> {
    guard let script = BitcoinScriptType(address: targetAddress, coin: coin) else {
        return .failure(.unsupportedAddressFormat)
    }
    return .just(script)
}
