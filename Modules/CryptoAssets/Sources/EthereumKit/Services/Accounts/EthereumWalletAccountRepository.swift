// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import DIKit
import Localization
import MetadataKit
import PlatformKit
import ToolKit
import WalletCore
import WalletPayloadKit

public enum WalletAccountRepositoryError: Error {
    case missingWallet
    case failedToFetchAccount(Error)
}

public protocol EthereumWalletAccountRepositoryAPI {

    var defaultAccount: AnyPublisher<EthereumWalletAccount, WalletAccountRepositoryError> { get }
}

protocol EthereumWalletRepositoryAPI {

    var ethereumEntry: AnyPublisher<EthereumEntryPayload?, WalletAccountRepositoryError> { get }

    func invalidateCache()
}

final class EthereumWalletAccountRepository: EthereumWalletAccountRepositoryAPI, EthereumWalletRepositoryAPI {

    // MARK: - Types

    private struct Key: Hashable {}

    // MARK: - EthereumWalletAccountRepositoryAPI

    let defaultAccount: AnyPublisher<EthereumWalletAccount, WalletAccountRepositoryError>

    let ethereumEntry: AnyPublisher<EthereumEntryPayload?, WalletAccountRepositoryError>

    // MARK: - Private Properties

    private let accountBridge: EthereumWalletAccountBridgeAPI
    private let cachedValue: CachedValueNew<
        Key,
        EthereumWallet,
        WalletAccountRepositoryError
    >
    private let walletCoreHDWalletProvider: WalletCoreHDWalletProvider

    // MARK: - Init

    init(
        accountBridge: EthereumWalletAccountBridgeAPI = resolve(),
        walletMetadataEntryService: WalletMetadataEntryServiceAPI = resolve(),
        walletCoreHDWalletProvider: @escaping WalletCoreHDWalletProvider = resolve(),
        nativeWalletEnabled: @escaping () -> AnyPublisher<Bool, Never> = { nativeWalletFlagEnabled() }
    ) {
        self.accountBridge = accountBridge
        self.walletCoreHDWalletProvider = walletCoreHDWalletProvider

        let cache: AnyCache<Key, EthereumWallet> = InMemoryCache(
            configuration: .onLoginLogout(),
            refreshControl: PerpetualCacheRefreshControl()
        ).eraseToAnyCache()

        let fetch_old = { [accountBridge] () -> AnyPublisher<EthereumWallet, WalletAccountRepositoryError> in
            accountBridge.wallets
                .eraseError()
                .mapError(WalletAccountRepositoryError.failedToFetchAccount)
                .map { accounts in
                    let walletAccounts = accounts.map { account in
                        EthereumWalletAccount(
                            index: account.index,
                            publicKey: account.publicKey,
                            label: account.label,
                            archived: account.archived
                        )
                    }
                    return EthereumWallet(entry: nil, accounts: walletAccounts)
                }
                .eraseToAnyPublisher()
        }

        let fetch_new = fetchOrCreateEthereumNatively(
            metadataService: walletMetadataEntryService,
            hdWalletProvider: walletCoreHDWalletProvider,
            label: LocalizationConstants.Account.myWallet
        )
        .flatMap { entry -> AnyPublisher<EthereumWallet, WalletAssetFetchError> in
            guard let ethereum = entry.ethereum else {
                return .failure(.notInitialized)
            }

            let accounts = ethereum.accounts.enumerated().map { index, account in
                EthereumWalletAccount(
                    index: index,
                    publicKey: account.address,
                    label: account.label,
                    archived: account.archived
                )
            }

            return .just(EthereumWallet(entry: entry, accounts: accounts))
        }
        .mapError(WalletAccountRepositoryError.failedToFetchAccount)
        .eraseToAnyPublisher()

        cachedValue = CachedValueNew(
            cache: cache,
            fetch: { [nativeWalletEnabled] _ in
                nativeWalletEnabled()
                    .flatMap { isEnabled -> AnyPublisher<EthereumWallet, WalletAccountRepositoryError> in
                        guard isEnabled else {
                            return fetch_old()
                        }
                        return fetch_new
                    }
                    .eraseToAnyPublisher()
            }
        )

        defaultAccount = cachedValue.get(key: Key())
            .map(\.accounts)
            .compactMap(\.first)
            .eraseToAnyPublisher()

        ethereumEntry = cachedValue.get(key: Key())
            .map(\.entry)
            .eraseToAnyPublisher()
    }

    func invalidateCache() {
        cachedValue.invalidateCache()
    }
}
