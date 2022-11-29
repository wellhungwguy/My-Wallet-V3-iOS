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

    private let cachedValue: CachedValueNew<
        Key,
        EthereumWallet,
        WalletAccountRepositoryError
    >
    private let walletCoreHDWalletProvider: WalletCoreHDWalletProvider

    // MARK: - Init

    init(
        walletMetadataEntryService: WalletMetadataEntryServiceAPI = resolve(),
        walletCoreHDWalletProvider: @escaping WalletCoreHDWalletProvider = resolve()
    ) {
        self.walletCoreHDWalletProvider = walletCoreHDWalletProvider

        let cache: AnyCache<Key, EthereumWallet> = InMemoryCache(
            configuration: .onLoginLogout(),
            refreshControl: PerpetualCacheRefreshControl()
        ).eraseToAnyCache()

        self.cachedValue = CachedValueNew(
            cache: cache,
            fetch: { _ -> AnyPublisher<EthereumWallet, WalletAccountRepositoryError> in
                fetchOrCreateEthereumNatively(
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
            }
        )

        self.defaultAccount = cachedValue.get(key: Key())
            .map(\.accounts)
            .compactMap(\.first)
            .eraseToAnyPublisher()

        self.ethereumEntry = cachedValue.get(key: Key())
            .map(\.entry)
            .eraseToAnyPublisher()
    }

    func invalidateCache() {
        cachedValue.invalidateCache()
    }
}
