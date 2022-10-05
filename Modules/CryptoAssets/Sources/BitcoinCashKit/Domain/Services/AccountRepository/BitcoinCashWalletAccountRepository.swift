// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BitcoinChainKit
import Combine
import DIKit
import PlatformKit
import RxSwift
import ToolKit
import WalletPayloadKit

public enum BitcoinCashWalletRepositoryError: Error {
    case missingWallet
    case failedToFetchAccount(Error)
}

final class BitcoinCashWalletAccountRepository {

    private struct Key: Hashable {}

    struct BCHAccounts: Equatable {
        let defaultAccount: BitcoinCashWalletAccount
        let accounts: [BitcoinCashWalletAccount]

        let entry: BitcoinCashEntry?
        var txNotes: [String: String]? {
            entry?.txNotes
        }
    }

    // MARK: - Properties

    let defaultAccount: AnyPublisher<BitcoinCashWalletAccount, BitcoinCashWalletRepositoryError>
    let accounts: AnyPublisher<[BitcoinCashWalletAccount], BitcoinCashWalletRepositoryError>
    let activeAccounts: AnyPublisher<[BitcoinCashWalletAccount], BitcoinCashWalletRepositoryError>
    let bitcoinCashEntry: AnyPublisher<BitcoinCashEntry?, BitcoinCashWalletRepositoryError>

    private let bitcoinCashFetcher: BitcoinCashEntryFetcherAPI
    private let cachedValue: CachedValueNew<
        Key,
        BCHAccounts,
        BitcoinCashWalletRepositoryError
    >

    // MARK: - Init

    init(
        bitcoinCashFetcher: BitcoinCashEntryFetcherAPI = resolve()
    ) {
        self.bitcoinCashFetcher = bitcoinCashFetcher

        let cache: AnyCache<Key, BCHAccounts> = InMemoryCache(
            configuration: .onLoginLogout(),
            refreshControl: PerpetualCacheRefreshControl()
        ).eraseToAnyCache()

        cachedValue = CachedValueNew(
            cache: cache,
            fetch: { [bitcoinCashFetcher] _ in
                bitcoinCashFetcher.fetchOrCreateBitcoinCash()
                    .mapError { _ in .missingWallet }
                    .map { entry in
                        let defaultAccount = bchWalletAccount(from: entry.defaultAccount)
                        let accounts = entry.accounts.map(bchWalletAccount(from:))
                        return BCHAccounts(defaultAccount: defaultAccount, accounts: accounts, entry: entry)
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

        bitcoinCashEntry = cachedValue.get(key: Key())
            .map(\.entry)
            .eraseToAnyPublisher()
    }

    func invalidateCache() {
        cachedValue.invalidateCache()
    }
}

private func bchWalletAccount(
    from entry: BitcoinCashEntry.AccountEntry
) -> BitcoinCashWalletAccount {
    BitcoinCashWalletAccount(
        index: entry.index,
        publicKey: entry.publicKey,
        label: entry.label ?? defaultLabel(using: entry.index),
        derivationType: derivationType(from: entry.derivationType),
        archived: entry.archived
    )
}

private func defaultLabel(using index: Int) -> String {
    let suffix = index > 0 ? "\(index)" : ""
    return "Private Key Wallet \(suffix)"
}

extension BitcoinCashWalletAccount {
    var isActive: Bool {
        !archived
    }
}
