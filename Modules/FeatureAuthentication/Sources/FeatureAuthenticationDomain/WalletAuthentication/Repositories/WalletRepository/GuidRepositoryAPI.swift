// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine

public protocol GuidRepositoryAPI: AnyObject {

    /// Streams `Bool` indicating whether the guid is currently cached in the repo
    var hasGuid: AnyPublisher<Bool, Never> { get }

    /// Streams the cached guid or `nil` if it is not cached
    var guid: AnyPublisher<String?, Never> { get }

    /// Sets the guid
    func set(guid: String) -> AnyPublisher<Void, Never>
}

extension GuidRepositoryAPI {

    public var hasGuid: AnyPublisher<Bool, Never> {
        guid
            .flatMap { guid -> AnyPublisher<Bool, Never> in
                guard let guid else { return .just(false) }
                return .just(!guid.isEmpty)
            }
            .eraseToAnyPublisher()
    }
}

public protocol LegacyGuidRepositoryAPI {
    /// Streams the cached guid or `nil` if it is not cached
    var guid: AnyPublisher<String?, Never> { get }
    var directGuid: String? { get }

    /// Sets the guid
    func set(guid: String?) -> AnyPublisher<Void, Never>

    func directSet(guid: String?)
}
