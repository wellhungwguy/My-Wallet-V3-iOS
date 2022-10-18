// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BigInt
import MoneyKit
import PlatformKit

public struct EthereumTransactionFee {

    // MARK: Types

    public enum FeeLevel {
        case regular
        case priority
    }

    // MARK: Static Methods

    private static let defaultGasLimit: BigUInt = 21000
    private static let defaultGasLimitContract: BigUInt = 75000

    private static func defaultRegularFee(network: EVMNetwork) -> CryptoValue {
        let gwei: BigInt
        switch network {
        case .avalanceCChain:
            gwei = 25
        case .binanceSmartChain:
            gwei = 5
        case .ethereum:
            gwei = 50
        case .polygon:
            gwei = 40
        }
        return .ether(gwei: gwei, network: network)
    }

    private static func defaultPriorityFee(network: EVMNetwork) -> CryptoValue {
        let gwei: BigInt
        switch network {
        case .avalanceCChain:
            gwei = 30
        case .binanceSmartChain:
            gwei = 7
        case .ethereum:
            gwei = 100
        case .polygon:
            gwei = 50
        }
        return .ether(gwei: gwei, network: network)
    }

    static func `default`(network: EVMNetwork) -> EthereumTransactionFee {
        EthereumTransactionFee(
            regular: Self.defaultRegularFee(network: network),
            priority: Self.defaultRegularFee(network: network),
            gasLimit: Self.defaultGasLimit,
            gasLimitContract: Self.defaultGasLimitContract,
            network: network
        )
    }

    // MARK: Private Properties

    private let regular: CryptoValue
    private let priority: CryptoValue
    private let gasLimit: BigUInt
    private let gasLimitContract: BigUInt
    private let network: EVMNetwork

    // MARK: Init

    init(
        regular: CryptoValue,
        priority: CryptoValue,
        gasLimit: BigUInt,
        gasLimitContract: BigUInt,
        network: EVMNetwork
    ) {
        self.regular = regular
        self.priority = priority
        self.gasLimit = gasLimit
        self.gasLimitContract = gasLimitContract
        self.network = network
    }

    init(
        regularGwei: Int,
        priorityGwei: Int,
        gasLimit: Int,
        gasLimitContract: Int,
        network: EVMNetwork
    ) {
        self.init(
            regular: .ether(gwei: BigInt(regularGwei), network: network),
            priority: .ether(gwei: BigInt(priorityGwei), network: network),
            gasLimit: BigUInt(gasLimit),
            gasLimitContract: BigUInt(gasLimitContract),
            network: network
        )
    }

    init(
        regularMinor: String,
        priorityMinor: String,
        gasLimit: String,
        gasLimitContract: String,
        network: EVMNetwork
    ) {
        self.init(
            regular: .create(minor: regularMinor, currency: network.cryptoCurrency) ?? Self.defaultRegularFee(network: network),
            priority: .create(minor: priorityMinor, currency: network.cryptoCurrency) ?? Self.defaultPriorityFee(network: network),
            gasLimit: BigUInt(gasLimit) ?? Self.defaultGasLimit,
            gasLimitContract: BigUInt(gasLimitContract) ?? Self.defaultGasLimitContract,
            network: network
        )
    }

    // MARK: Private Methods

    public func gasPrice(feeLevel: FeeLevel) -> BigUInt {
        switch feeLevel {
        case .regular:
            return BigUInt(regular.minorAmount)
        case .priority:
            return BigUInt(priority.minorAmount)
        }
    }

    public func gasLimit(
        extraGasLimit: BigUInt,
        isContract: Bool
    ) -> BigUInt {
        (isContract ? gasLimitContract : gasLimit) + extraGasLimit
    }

    public func absoluteFee(
        with feeLevel: FeeLevel,
        extraGasLimit: BigUInt,
        isContract: Bool
    ) -> CryptoValue {
        let price = gasPrice(feeLevel: feeLevel)
        let gasLimit = gasLimit(extraGasLimit: extraGasLimit, isContract: isContract)
        let amount = price * gasLimit
        return CryptoValue
            .create(
                minor: BigInt(amount),
                currency: network.cryptoCurrency
            )
    }
}

extension CryptoValue {

    static func ether(
        gwei: BigInt,
        network: EVMNetwork
    ) -> CryptoValue {
        let wei = gwei * BigInt(1e9)
        return CryptoValue.create(
            minor: wei,
            currency: network.cryptoCurrency
        )
    }
}
