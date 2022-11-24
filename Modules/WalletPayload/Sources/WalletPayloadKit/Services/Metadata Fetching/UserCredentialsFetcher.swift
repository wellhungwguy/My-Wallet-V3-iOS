// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import Foundation
import MetadataKit
import ToolKit

public struct UserCredentials: Equatable {
    public let userId: String
    public let lifetimeToken: String

    public init(userId: String, lifetimeToken: String) {
        self.userId = userId
        self.lifetimeToken = lifetimeToken
    }

    static func from(entry: UserCredentialsEntryPayload) -> Self {
        UserCredentials(
            userId: entry.userId,
            lifetimeToken: entry.lifetimeToken
        )
    }

    func toEntry() -> UserCredentialsEntryPayload {
        UserCredentialsEntryPayload(
            userId: userId,
            lifetimeToken: lifetimeToken
        )
    }
}

public protocol UserCredentialsFetcherAPI {
    /// Fetches the `UserCredentials` from Wallet metadata
    func fetchUserCredentials(forceFetch: Bool) -> AnyPublisher<UserCredentials, WalletAssetFetchError>

    /// Stores the passed UserCredentials to metadata
    /// - Parameter credentials: A `UserCredentials` value
    func store(credentials: UserCredentials) -> AnyPublisher<EmptyValue, WalletAssetSaveError>
}

final class UserCredentialsFetcher: UserCredentialsFetcherAPI {
    private struct Key: Hashable {}

    private let metadataEntryService: WalletMetadataEntryServiceAPI

    private let cachedValue: CachedValueNew<Key, UserCredentials, WalletAssetFetchError>

    init(metadataEntryService: WalletMetadataEntryServiceAPI) {
        self.metadataEntryService = metadataEntryService
        let cache = InMemoryCache<Key, UserCredentials>(
            configuration: .onLoginLogout(),
            refreshControl: PerpetualCacheRefreshControl()
        )
        .eraseToAnyCache()

        self.cachedValue = CachedValueNew(
            cache: cache,
            fetch: { [metadataEntryService] _ in
                doFetchUserCredentialsEntry(
                    service: metadataEntryService
                )
            }
        )
    }

    func fetchUserCredentials(forceFetch: Bool) -> AnyPublisher<UserCredentials, WalletAssetFetchError> {
        cachedValue.get(
            key: Key(),
            forceFetch: forceFetch
        )
    }

    func store(credentials: UserCredentials) -> AnyPublisher<EmptyValue, WalletAssetSaveError> {
        metadataEntryService.save(node: credentials.toEntry())
    }
}

private func doFetchUserCredentialsEntry(
    service: WalletMetadataEntryServiceAPI
) -> AnyPublisher<UserCredentials, WalletAssetFetchError> {
    service.fetchEntry(type: UserCredentialsEntryPayload.self)
        .map(UserCredentials.from(entry:))
        .eraseToAnyPublisher()
}
