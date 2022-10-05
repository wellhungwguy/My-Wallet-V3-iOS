// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BitcoinChainKit
import Combine
import DIKit
import PlatformKit
import RxSwift
import ToolKit
import WalletPayloadKit

public enum BitcoinWalletRepositoryError: Error {
    case missingWallet
    case unableToRetrieveNote
    case failedToFetchAccount(Error)
}

final class BitcoinWalletAccountRepository {

    private struct Key: Hashable {}

    struct BTCAccounts: Equatable {
        let defaultAccount: BitcoinWalletAccount
        let accounts: [BitcoinWalletAccount]
    }

    // MARK: - Properties

    let defaultAccount: AnyPublisher<BitcoinWalletAccount, BitcoinWalletRepositoryError>
    let accounts: AnyPublisher<[BitcoinWalletAccount], BitcoinWalletRepositoryError>
    let activeAccounts: AnyPublisher<[BitcoinWalletAccount], BitcoinWalletRepositoryError>

    private let cachedValue: CachedValueNew<
        Key,
        BTCAccounts,
        BitcoinWalletRepositoryError
    >
    private let bitcoinEntryFetcher: BitcoinEntryFetcherAPI

    // MARK: - Init

    init(bitcoinEntryFetcher: BitcoinEntryFetcherAPI = resolve()) {
        self.bitcoinEntryFetcher = bitcoinEntryFetcher

        let cache: AnyCache<Key, BTCAccounts> = InMemoryCache(
            configuration: .onLoginLogout(),
            refreshControl: PerpetualCacheRefreshControl()
        ).eraseToAnyCache()

        cachedValue = CachedValueNew(
            cache: cache,
            fetch: { _ in
                bitcoinEntryFetcher.fetchOrCreateBitcoin()
                    .mapError { _ in .missingWallet }
                    .map { entry in
                        let defaultIndex = entry.defaultAccountIndex
                        let defaultAccount = btcWalletAccount(from: entry.accounts[defaultIndex])
                        let accounts = entry.accounts.map(btcWalletAccount(from:))
                        return BTCAccounts(defaultAccount: defaultAccount, accounts: accounts)
                    }
                    .eraseToAnyPublisher()
            }
        )

        defaultAccount = cachedValue.get(key: Key())
            .map(\.defaultAccount)
            .eraseToAnyPublisher()

        accounts = cachedValue.get(key: Key())
            .map(\.accounts)
            .eraseToAnyPublisher()

        activeAccounts = accounts
            .map { accounts in
                accounts.filter(\.isActive)
            }
            .eraseToAnyPublisher()
    }
}

private func btcWalletAccount(
    from entry: BitcoinEntry.Account
) -> BitcoinWalletAccount {
    let publicKeys = entry.xpubs.map { xpub in
        XPub(address: xpub.address, derivationType: derivationType(from: xpub.type))
    }
    return BitcoinWalletAccount(
        index: entry.index,
        label: entry.label,
        archived: entry.archived,
        publicKeys: XPubs(xpubs: publicKeys)
    )
}
