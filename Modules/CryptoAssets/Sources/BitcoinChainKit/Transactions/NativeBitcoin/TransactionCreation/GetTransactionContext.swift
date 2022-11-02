// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import Errors
import ToolKit
import WalletCore

struct NativeBitcoinTransactionContext {
    let accountKeyContext: AccountKeyContext
    let unspentOutputs: [UnspentOutput]
    let multiAddressItems: [AddressItem]
    let coin: BitcoinChainCoin
    let keyPairs: [WalletKeyPair]

    init(accountKeyContext: AccountKeyContext, unspentOutputs: [UnspentOutput], multiAddressItems: [AddressItem], coin: BitcoinChainCoin) {
        self.accountKeyContext = accountKeyContext
        self.unspentOutputs = unspentOutputs
        self.multiAddressItems = multiAddressItems
        self.coin = coin
        self.keyPairs = getWalletKeyPairs(
            unspentOutputs: unspentOutputs,
            accountKeyContext: accountKeyContext
        )
    }
}

typealias TransactionContextFor =
    (BitcoinChainAccount) -> AnyPublisher<NativeBitcoinTransactionContext, Error>

func getTransactionContext(
    for account: BitcoinChainAccount,
    transactionContextFor: TransactionContextFor
) -> AnyPublisher<NativeBitcoinTransactionContext, Error> {
    transactionContextFor(account)
}

func getTransactionContextProvider(
    walletMnemonicProvider: @escaping WalletMnemonicProvider,
    fetchUnspentOutputsFor: @escaping FetchUnspentOutputsFor,
    fetchMultiAddressFor: @escaping FetchMultiAddressFor
) -> (BitcoinChainAccount) -> AnyPublisher<NativeBitcoinTransactionContext, Error> {
    { [walletMnemonicProvider] account in
        getAccountKeys(
            for: account,
            walletMnemonicProvider: walletMnemonicProvider
        )
        .flatMap { context -> AnyPublisher<NativeBitcoinTransactionContext, Error> in
            let xpubs = context.xpubs
            let unspentOutputsPublisher = getUnspentOutputs(
                for: account,
                xpubs: xpubs,
                fetchUnspentOutputsFor: fetchUnspentOutputsFor
            )
            let multiAddressPublisher = getMultiAddress(
                xpubs: xpubs,
                fetchMultiAddressFor: fetchMultiAddressFor
            )
            return Publishers.Zip(unspentOutputsPublisher, multiAddressPublisher)
                .map { unspentOutputs, addressItems in
                    (context, unspentOutputs, addressItems, account.coin)
                }
                .map(NativeBitcoinTransactionContext.init)
                .eraseToAnyPublisher()
        }
        .eraseToAnyPublisher()
    }
}

private func getUnspentOutputs(
    for account: BitcoinChainAccount,
    xpubs: [XPub],
    fetchUnspentOutputsFor: FetchUnspentOutputsFor
) -> AnyPublisher<[UnspentOutput], Error> {
    fetchUnspentOutputsFor(xpubs)
        .map(\.outputs)
        .eraseError()
}
