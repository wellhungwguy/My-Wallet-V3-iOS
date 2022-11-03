// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine

public protocol SessionTokenRepositoryAPI: AnyObject {

    /// Streams `Bool` indicating whether a session token is currently cached in the repo
    var hasSessionToken: AnyPublisher<Bool, Never> { get }

    /// Streams the cached session token or `nil` if it is not cached
    var sessionToken: AnyPublisher<String?, Never> { get }

    /// Sets the session token
    func set(sessionToken: String) -> AnyPublisher<Void, Never>

    /// Cleans the session token
    func cleanSessionToken() -> AnyPublisher<Void, Never>
}

extension SessionTokenRepositoryAPI {

    public var hasSessionToken: AnyPublisher<Bool, Never> {
        sessionToken
            .flatMap { token -> AnyPublisher<Bool, Never> in
                guard let token else { return .just(false) }
                return .just(!token.isEmpty)
            }
            .eraseToAnyPublisher()
    }
}
