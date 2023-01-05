// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import Foundation
import MetadataKit
import ToolKit

public struct AccountCredentials: Equatable {
    public let nabuUserId: String
    public let nabuLifetimeToken: String
    public let exchangeUserId: String?
    public let exchangeLifetimeToken: String?

    public init(
        nabuUserId: String,
        nabuLifetimeToken: String,
        exchangeUserId: String?,
        exchangeLifetimeToken: String?
    ) {
        self.nabuUserId = nabuUserId
        self.nabuLifetimeToken = nabuLifetimeToken
        self.exchangeUserId = exchangeUserId
        self.exchangeLifetimeToken = exchangeLifetimeToken
    }

    static func from(entry: AccountCredentialsEntryPayload) -> Self {
        AccountCredentials(
            nabuUserId: entry.nabuUserId,
            nabuLifetimeToken: entry.nabuLifetimeToken,
            exchangeUserId: entry.exchangeUserId,
            exchangeLifetimeToken: entry.exchangeLifetimeToken
        )
    }

    func toEntry() -> AccountCredentialsEntryPayload {
        AccountCredentialsEntryPayload(
            nabuUserId: nabuUserId,
            nabuLifetimeToken: nabuLifetimeToken,
            exchangeUserId: exchangeUserId,
            exchangeLifetimeToken: exchangeLifetimeToken
        )
    }
}

public protocol AccountCredentialsFetcherAPI {
    /// Fetches the `UserCredentials` from Wallet metadata
    func fetchAccountCredentials(forceFetch: Bool) -> AnyPublisher<AccountCredentials, WalletAssetFetchError>

    /// Stores the passed UserCredentials to metadata
    /// - Parameter credentials: A `UserCredentials` value
    func store(credentials: AccountCredentials) -> AnyPublisher<EmptyValue, WalletAssetSaveError>
}

final class AccountCredentialsFetcher: AccountCredentialsFetcherAPI {
    private struct Key: Hashable {}

    private let metadataEntryService: WalletMetadataEntryServiceAPI
    private let userCredentialsFetcher: UserCredentialsFetcherAPI
    private let featureFlagService: FeatureFlagsServiceAPI

    private let cachedValue: CachedValueNew<Key, AccountCredentials, WalletAssetFetchError>

    init(
        metadataEntryService: WalletMetadataEntryServiceAPI,
        userCredentialsFetcher: UserCredentialsFetcherAPI,
        featureFlagService: FeatureFlagsServiceAPI
    ) {
        self.metadataEntryService = metadataEntryService
        self.userCredentialsFetcher = userCredentialsFetcher
        self.featureFlagService = featureFlagService

        let cache = InMemoryCache<Key, AccountCredentials>(
            configuration: .onLoginLogout(),
            refreshControl: PerpetualCacheRefreshControl()
        )
        .eraseToAnyCache()

        self.cachedValue = CachedValueNew(
            cache: cache,
            fetch: { [featureFlagService, userCredentialsFetcher, metadataEntryService] _ in
                doFetchAccountCredentials(
                    forceFetch: true,
                    flagsService: featureFlagService,
                    metadataEntryService: metadataEntryService,
                    userCredentialsFetcher: userCredentialsFetcher
                )
            }
        )
    }

    func fetchAccountCredentials(forceFetch: Bool) -> AnyPublisher<AccountCredentials, WalletAssetFetchError> {
        cachedValue.get(
            key: Key(),
            forceFetch: forceFetch
        )
    }

    func store(credentials: AccountCredentials) -> AnyPublisher<EmptyValue, WalletAssetSaveError> {
        doSave(
            credentials: credentials,
            flagsService: featureFlagService,
            metadataEntryService: metadataEntryService,
            userCredentialsFetcher: userCredentialsFetcher
        )
    }
}

private func doFetchAccountCredentials(
    forceFetch: Bool,
    flagsService: FeatureFlagsServiceAPI,
    metadataEntryService: WalletMetadataEntryServiceAPI,
    userCredentialsFetcher: UserCredentialsFetcherAPI
) -> AnyPublisher<AccountCredentials, WalletAssetFetchError> {
    flagsService.isEnabled(.accountCredentialsMetadataMigration)
        .flatMap { [metadataEntryService, userCredentialsFetcher] isEnabled
            -> AnyPublisher<AccountCredentials, WalletAssetFetchError> in
            guard isEnabled else {
                // fetch legacy if ff is not enabled
                return userCredentialsFetcher.fetchUserCredentials(forceFetch: forceFetch)
                    .map { entry in
                        AccountCredentials(
                            nabuUserId: entry.userId,
                            nabuLifetimeToken: entry.lifetimeToken,
                            exchangeUserId: nil,
                            exchangeLifetimeToken: nil
                        )
                    }
                    .eraseToAnyPublisher()
            }
            return metadataEntryService.fetchEntry(type: AccountCredentialsEntryPayload.self)
                .map(AccountCredentials.from(entry:))
                .zip(userCredentialsFetcher.fetchUserCredentials(forceFetch: forceFetch))
                .map { accountCredentials, userCredentials in
                    guard !accountCredentials.nabuUserId.isEmpty,
                          !accountCredentials.nabuLifetimeToken.isEmpty
                    else {
                        return AccountCredentials(
                            nabuUserId: userCredentials.userId,
                            nabuLifetimeToken: userCredentials.lifetimeToken,
                            exchangeUserId: nil,
                            exchangeLifetimeToken: nil
                        )
                    }
                    return accountCredentials
                }
                .eraseToAnyPublisher()
        }
        .eraseToAnyPublisher()
}

private func doSave(
    credentials: AccountCredentials,
    flagsService: FeatureFlagsServiceAPI,
    metadataEntryService: WalletMetadataEntryServiceAPI,
    userCredentialsFetcher: UserCredentialsFetcherAPI
) -> AnyPublisher<EmptyValue, WalletAssetSaveError> {
    flagsService.isEnabled(.accountCredentialsMetadataMigration)
        .flatMap { [metadataEntryService, userCredentialsFetcher] isEnabled
            -> AnyPublisher<EmptyValue, WalletAssetSaveError> in
            guard isEnabled else {
                return userCredentialsFetcher.store(
                    credentials: UserCredentials(
                        userId: credentials.nabuUserId,
                        lifetimeToken: credentials.nabuLifetimeToken
                    )
                )
            }
            // we're also saving to the old entry (10) as well as the new one
            let userCredentials = UserCredentials(
                userId: credentials.nabuUserId,
                lifetimeToken: credentials.nabuLifetimeToken
            )
            return metadataEntryService.save(node: credentials.toEntry())
                .zip(userCredentialsFetcher.store(credentials: userCredentials))
                .map { _ in .noValue }
                .eraseToAnyPublisher()
        }
        .eraseToAnyPublisher()
}
