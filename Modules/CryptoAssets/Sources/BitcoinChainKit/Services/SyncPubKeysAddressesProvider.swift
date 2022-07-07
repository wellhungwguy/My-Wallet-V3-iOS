// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import DIKit
import Foundation
import WalletPayloadKit

final class SyncPubKeysAddressesProvider: SyncPubKeysAddressesProviderAPI {

    private static let defaultLookAheadCount: UInt32 = 10

    private let addressProvider: BitcoinChainReceiveAddressProviderAPI
    private let mnemonicProvider: WalletMnemonicProvider
    private let fetchMultiAddressFor: FetchMultiAddressFor

    init(
        addressProvider: BitcoinChainReceiveAddressProviderAPI,
        mnemonicProvider: @escaping WalletMnemonicProvider,
        fetchMultiAddressFor: @escaping FetchMultiAddressFor
    ) {
        self.addressProvider = addressProvider
        self.mnemonicProvider = mnemonicProvider
        self.fetchMultiAddressFor = fetchMultiAddressFor
    }

    func provideAddresses(
        active: [String],
        accounts: [Account]
    ) -> AnyPublisher<String, SyncPubKeysAddressesProviderError> {
        hdAccountAddresses(
            accounts: accounts,
            coin: .bitcoin,
            lookupAheadCount: Self.defaultLookAheadCount
        )
        .map { hdAddresses -> [String] in
            let flattenedAddresses = hdAddresses.flatMap { $0 }
            return active + flattenedAddresses
        }
        .map { addresses -> String in
            addresses.joined(separator: "|")
        }
        .eraseToAnyPublisher()
    }

    private func hdAccountAddresses(
        accounts: [Account],
        coin: BitcoinChainCoin,
        lookupAheadCount: UInt32
    ) -> AnyPublisher<[[String]], SyncPubKeysAddressesProviderError> {
        accounts.publisher
            .flatMap { [mnemonicProvider, fetchMultiAddressFor] account
                -> AnyPublisher<[String], SyncPubKeysAddressesProviderError> in
                receiveIndex(
                    account: account,
                    coin: coin,
                    mnemonicProvider: mnemonicProvider,
                    fetchMultiAddressFor: fetchMultiAddressFor
                )
                .map { context, receivedIndex -> (AccountKeyContext, Range<UInt32>) in
                    let receiveIndexRange: Range<UInt32> = receivedIndex..<(receivedIndex + lookupAheadCount)
                    return (context, receiveIndexRange)
                }
                .map { context, range -> [String] in
                    range
                        .map { receiveIndex in
                            deriveReceiveAddress(
                                context: context,
                                coin: coin,
                                receiveIndex: receiveIndex
                            )
                        }
                }
                .eraseToAnyPublisher()
            }
            .collect()
            .mapError { _ in SyncPubKeysAddressesProviderError.failureProvidingAddresses }
            .eraseToAnyPublisher()
    }
}

/// Retrieves the receive index of a given account
private func receiveIndex(
    account: Account,
    coin: BitcoinChainCoin,
    mnemonicProvider: @escaping WalletMnemonicProvider,
    fetchMultiAddressFor: @escaping FetchMultiAddressFor
) -> AnyPublisher<(AccountKeyContext, UInt32), SyncPubKeysAddressesProviderError> {
    let bitcoinChainAccount = BitcoinChainAccount(index: Int32(account.index), coin: coin)
    return getAccountKeys(
        for: bitcoinChainAccount,
        walletMnemonicProvider: mnemonicProvider
    )
    .flatMap { [fetchMultiAddressFor] context
        -> AnyPublisher<(AccountKeyContext, UInt32), Error> in
        let xpubs = context.xpubs
        let multiAddressPublisher = getMultiAddress(
            xpubs: xpubs,
            fetchMultiAddressFor: fetchMultiAddressFor
        )
        return multiAddressPublisher
            .map { addressItems in
                let defaultAddress = addressItems.first(where: {
                    $0.xpub == context.defaultDerivation(coin: coin).xpub
                })
                guard let address = defaultAddress else {
                    return 0
                }
                return UInt32(address.accountIndex)
            }
            .map { receiveIndex in
                (context, receiveIndex)
            }
            .eraseToAnyPublisher()
    }
    .mapError { _ in SyncPubKeysAddressesProviderError.failureProvidingAddresses }
    .eraseToAnyPublisher()
}
