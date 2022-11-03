// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import Errors
import WalletPayloadKit

// MARK: - Types

public enum GuidServiceError: Error {
    case missingSessionToken
    case missingGuid
    case networkError(NetworkError)
}

public protocol GuidServiceAPI: AnyObject {
    /// An `AnyPublisher` that streams the `GUID` on success or fails due
    /// to a missing resource or network error.
    var guid: AnyPublisher<String, GuidServiceError> { get }
}

final class GuidService: GuidServiceAPI {

    // MARK: - Properties

    /// Fetches the `GUID`
    let guid: AnyPublisher<String, GuidServiceError>

    private let sessionTokenRepository: SessionTokenRepositoryAPI
    private let guidRepository: RemoteGuidRepositoryAPI

    // MARK: - Setup

    init(
        sessionTokenRepository: SessionTokenRepositoryAPI,
        guidRepository: RemoteGuidRepositoryAPI
    ) {
        self.sessionTokenRepository = sessionTokenRepository
        self.guidRepository = guidRepository

        guid = sessionTokenRepository
            .sessionToken
            .flatMap { [guidRepository] token -> AnyPublisher<String?, GuidServiceError> in
                guard let token else {
                    return .failure(.missingSessionToken)
                }
                return guidRepository.guid(token: token)
            }
            .flatMap { guidOrNil -> AnyPublisher<String, GuidServiceError> in
                guard let guid = guidOrNil else {
                    return .failure(.missingGuid)
                }
                return .just(guid)
            }
            .share()
            .eraseToAnyPublisher()
    }
}
