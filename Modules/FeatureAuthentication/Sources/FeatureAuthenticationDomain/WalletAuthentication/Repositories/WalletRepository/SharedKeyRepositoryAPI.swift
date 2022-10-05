// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import WalletPayloadKit

public protocol SharedKeyRepositoryAPI: AnyObject {
    /// Streams `Bool` indicating whether the shared key is currently cached in the repo
    var hasSharedKey: AnyPublisher<Bool, Never> { get }

    /// Streams the cached shared key or `nil` if it is not cached
    var sharedKey: AnyPublisher<String?, Never> { get }

    /// Sets the shared key
    func set(sharedKey: String) -> AnyPublisher<Void, Never>
}

extension SharedKeyRepositoryAPI {

    public var hasSharedKey: AnyPublisher<Bool, Never> {
        sharedKey
            .map { sharedKey -> Bool in
                guard let sharedKey = sharedKey else { return false }
                return !sharedKey.isEmpty
            }
            .eraseToAnyPublisher()
    }
}

public protocol LegacySharedKeyRepositoryAPI {
    /// Streams the cached shared key or `nil` if it is not cached
    var sharedKey: AnyPublisher<String?, Never> { get }
    var directSharedKey: String? { get }

    /// Sets the shared key
    func set(sharedKey: String?) -> AnyPublisher<Void, Never>
    func directSet(sharedKey: String?)
}

public protocol CredentialsRepositoryAPI: SharedKeyRepositoryAPI, GuidRepositoryAPI {

    var credentials: AnyPublisher<(guid: String, sharedKey: String), MissingCredentialsError> { get }
}

extension CredentialsRepositoryAPI {

    public var credentials: AnyPublisher<(guid: String, sharedKey: String), MissingCredentialsError> {
        guid
            .zip(sharedKey)
            .flatMap { credentials -> AnyPublisher<(guid: String, sharedKey: String), MissingCredentialsError> in
                guard let guid = credentials.0 else {
                    return .failure(.guid)
                }
                guard let sharedKey = credentials.1 else {
                    return .failure(.sharedKey)
                }
                return .just((guid, sharedKey))
            }
            .eraseToAnyPublisher()
    }
}
