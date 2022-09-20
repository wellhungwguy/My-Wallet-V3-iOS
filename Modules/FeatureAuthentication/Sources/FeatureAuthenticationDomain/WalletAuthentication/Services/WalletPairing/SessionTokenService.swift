// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import DIKit
import Errors

public enum SessionTokenServiceError: Error, Equatable {
    case networkError(NetworkError)
    case missingSessionToken
}

public protocol SessionTokenServiceAPI: AnyObject {
    func setupSessionToken() -> AnyPublisher<Void, SessionTokenServiceError>
}

final class SessionTokenService: SessionTokenServiceAPI {

    // MARK: - Injected

    private let repository: RemoteSessionTokenRepositoryAPI
    private let sessionRepository: SessionTokenRepositoryAPI

    // MARK: - Setup

    init(
        repository: RemoteSessionTokenRepositoryAPI = resolve(),
        sessionRepository: SessionTokenRepositoryAPI
    ) {
        self.repository = repository
        self.sessionRepository = sessionRepository
    }

    func setupSessionToken() -> AnyPublisher<Void, SessionTokenServiceError> {
        repository
            .token
            .flatMap { sessionTokenOrNil
                -> AnyPublisher<String, SessionTokenServiceError> in
                guard let sessionToken = sessionTokenOrNil else {
                    return .failure(.missingSessionToken)
                }
                return .just(sessionToken)
            }
            .flatMap { [sessionRepository] sessionToken
                -> AnyPublisher<Void, SessionTokenServiceError> in
                sessionRepository.set(sessionToken: sessionToken)
                    .mapError()
            }
            .eraseToAnyPublisher()
    }
}
