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

    struct BCHAccounts: Equatable {
        let defaultAccount: BitcoinCashWalletAccount
        let accounts: [BitcoinCashWalletAccount]

        let entry: BitcoinCashEntry?
        var txNotes: [String: String]? {
            entry?.txNotes
        }
    }

    // MARK: - Properties

    private struct Key: Hashable {}

    let defaultAccount: AnyPublisher<BitcoinCashWalletAccount, BitcoinCashWalletRepositoryError>
    let accounts: AnyPublisher<[BitcoinCashWalletAccount], BitcoinCashWalletRepositoryError>

    let activeAccounts: AnyPublisher<[BitcoinCashWalletAccount], BitcoinCashWalletRepositoryError>

    let bitcoinCashEntry: AnyPublisher<BitcoinCashEntry?, BitcoinCashWalletRepositoryError>

    private let bitcoinCashFetcher: BitcoinCashEntryFetcherAPI
    private let bridge: BitcoinCashWalletBridgeAPI

    private let cachedValue: CachedValueNew<
        Key,
        BCHAccounts,
        BitcoinCashWalletRepositoryError
    >

    // MARK: - Init

    init(
        bridge: BitcoinCashWalletBridgeAPI = resolve(),
        bitcoinCashFetcher: BitcoinCashEntryFetcherAPI = resolve(),
        nativeWalletEnabled: @escaping () -> AnyPublisher<Bool, Never> = { nativeWalletFlagEnabled() }
    ) {
        self.bridge = bridge
        self.bitcoinCashFetcher = bitcoinCashFetcher

        let cache: AnyCache<Key, BCHAccounts> = InMemoryCache(
            configuration: .onLoginLogout(),
            refreshControl: PerpetualCacheRefreshControl()
        ).eraseToAnyCache()

        let fetch_old = { [bridge] () -> AnyPublisher<BCHAccounts, BitcoinCashWalletRepositoryError> in
            bridge.defaultWallet.asPublisher()
                .zip(bridge.wallets.asPublisher())
                .map { BCHAccounts(defaultAccount: $0, accounts: $1, entry: nil) }
                .mapError(BitcoinCashWalletRepositoryError.failedToFetchAccount)
                .eraseToAnyPublisher()
        }

        let fetch_new = { [bitcoinCashFetcher] () -> AnyPublisher<BCHAccounts, BitcoinCashWalletRepositoryError> in
            bitcoinCashFetcher.fetchOrCreateBitcoinCash()
                .mapError { _ in .missingWallet }
                .map { entry in
                    let defaultAccount = bchWalletAccount(from: entry.defaultAccount)
                    let accounts = entry.accounts.map(bchWalletAccount(from:))
                    return BCHAccounts(defaultAccount: defaultAccount, accounts: accounts, entry: entry)
                }
                .eraseToAnyPublisher()
        }

        cachedValue = CachedValueNew(
            cache: cache,
            fetch: { [nativeWalletEnabled] _ in
                nativeWalletEnabled()
                    .flatMap { isEnabled -> AnyPublisher<BCHAccounts, BitcoinCashWalletRepositoryError> in
                        guard isEnabled else {
                            return fetch_old()
                        }
                        return fetch_new()
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
