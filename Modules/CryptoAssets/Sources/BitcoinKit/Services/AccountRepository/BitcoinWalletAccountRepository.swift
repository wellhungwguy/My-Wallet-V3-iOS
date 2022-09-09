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
    private let bridge: BitcoinWalletBridgeAPI

    // MARK: - Init

    init(
        bridge: BitcoinWalletBridgeAPI = resolve(),
        bitcoinEntryFetcher: BitcoinEntryFetcherAPI = resolve(),
        nativeWalletEnabled: @escaping () -> AnyPublisher<Bool, Never> = { nativeWalletFlagEnabled() }
    ) {
        self.bridge = bridge

        let cache: AnyCache<Key, BTCAccounts> = InMemoryCache(
            configuration: .onLoginLogout(),
            refreshControl: PerpetualCacheRefreshControl()
        ).eraseToAnyCache()

        let fetch_old = { [bridge] () -> AnyPublisher<BTCAccounts, BitcoinWalletRepositoryError> in
            bridge.defaultWallet.asPublisher()
                .zip(bridge.wallets.asPublisher())
                .map { BTCAccounts(defaultAccount: $0, accounts: $1) }
                .mapError(BitcoinWalletRepositoryError.failedToFetchAccount)
                .eraseToAnyPublisher()
        }

        let fetch_new = { [bitcoinEntryFetcher] () -> AnyPublisher<BTCAccounts, BitcoinWalletRepositoryError> in
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

        cachedValue = CachedValueNew(
            cache: cache,
            fetch: { [nativeWalletEnabled] _ in
                nativeWalletEnabled()
                    .flatMap { isEnabled -> AnyPublisher<BTCAccounts, BitcoinWalletRepositoryError> in
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
