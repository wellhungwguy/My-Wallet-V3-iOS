// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import DIKit
import Foundation

public protocol BitcoinChainReceiveAddressProviderAPI {
    /// Returns the address for the specified account index using the current loaded wallet
    ///
    /// - Parameter accountIndex: A `UInt32` which specifies the account index
    /// - Returns: `AnyPublisher<String, Error>`
    func receiveAddressProvider(_ accountIndex: UInt32) -> AnyPublisher<String, Error>

    /// Returns the address for the specified account index and receive index using the current loaded wallet
    ///
    /// - Parameter accountIndex: A `UInt32` which specifies the account index
    /// - Parameter receiveIndex: A `UInt32` which specifies the receive index
    /// - Returns: `AnyPublisher<String, Error>`
    func receiveAddressProvider(_ accountIndex: UInt32, receiveIndex: UInt32) -> AnyPublisher<String, Error>

    /// Returns the first address for the specified account index using the current loaded wallet
    ///
    /// - Parameter accountIndex: A `UInt32` which specifies the account index
    /// - Returns: `AnyPublisher<String, Error>`
    func firstReceiveAddressProvider(_ accountIndex: UInt32) -> AnyPublisher<String, Error>
}

final class BitcoinChainReceiveAddressProvider<Token: BitcoinChainToken>: BitcoinChainReceiveAddressProviderAPI {

    private let mnemonicProvider: WalletMnemonicProvider
    private let fetchMultiAddressFor: FetchMultiAddressFor
    private let unspentOutputRepository: UnspentOutputRepositoryAPI

    init(
        mnemonicProvider: @escaping WalletMnemonicProvider,
        fetchMultiAddressFor: @escaping FetchMultiAddressFor,
        unspentOutputRepository: UnspentOutputRepositoryAPI
    ) {
        self.mnemonicProvider = mnemonicProvider
        self.fetchMultiAddressFor = fetchMultiAddressFor
        self.unspentOutputRepository = unspentOutputRepository
    }

    func receiveAddressProvider(_ accountIndex: UInt32) -> AnyPublisher<String, Error> {
        let account = BitcoinChainAccount(index: Int32(accountIndex), coin: Token.coin)
        let transactionContext = getTransactionContextProvider(
            walletMnemonicProvider: mnemonicProvider,
            fetchUnspentOutputsFor: unspentOutputRepository.unspentOutputs(for:),
            fetchMultiAddressFor: fetchMultiAddressFor
        )
        return getTransactionContext(
            for: account,
            transactionContextFor: transactionContext
        )
        .map { context -> ReceiveAddressContext in
            receiveAddressContext(
                for: context.multiAddressItems,
                coin: Token.coin,
                context: context.accountKeyContext
            )
        }
        .map(\.receiveAddress)
        .eraseError()
        .eraseToAnyPublisher()
    }

    func receiveAddressProvider(_ accountIndex: UInt32, receiveIndex: UInt32) -> AnyPublisher<String, Error> {
        let account = BitcoinChainAccount(index: Int32(accountIndex), coin: Token.coin)
        return getAccountKeys(
            for: account,
            walletMnemonicProvider: mnemonicProvider
        )
        .map { accountKeyContext -> String in
            deriveReceiveAddress(
                context: accountKeyContext,
                coin: Token.coin,
                receiveIndex: receiveIndex
            )
        }
        .eraseToAnyPublisher()
    }

    func firstReceiveAddressProvider(_ accountIndex: UInt32) -> AnyPublisher<String, Error> {
        receiveAddressProvider(
            accountIndex,
            receiveIndex: 0
        )
    }
}
