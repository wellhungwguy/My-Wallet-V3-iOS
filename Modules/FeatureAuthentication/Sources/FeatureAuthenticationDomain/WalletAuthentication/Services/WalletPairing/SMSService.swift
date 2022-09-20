// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import Errors
import Foundation
import ToolKit
import WalletPayloadKit

/// A potential SMS service error
public enum SMSServiceError: LocalizedError, Equatable {

    /// missing credentials
    case missingCredentials(MissingCredentialsError)

    /// other network errors
    case networkError(NetworkError)
}

public protocol SMSServiceAPI: AnyObject {
    /// Requests SMS OTP
    func request() -> AnyPublisher<Void, SMSServiceError>
}

final class SMSService: SMSServiceAPI {

    // MARK: - Properties

    private let smsRepository: SMSRepositoryAPI
    private let credentialsRepository: CredentialsRepositoryAPI
    private let sessionTokenRepository: SessionTokenRepositoryAPI

    init(
        smsRepository: SMSRepositoryAPI,
        credentialsRepository: CredentialsRepositoryAPI,
        sessionTokenRepository: SessionTokenRepositoryAPI
    ) {
        self.smsRepository = smsRepository
        self.credentialsRepository = credentialsRepository
        self.sessionTokenRepository = sessionTokenRepository
    }

    // MARK: - API

    func request() -> AnyPublisher<Void, SMSServiceError> {
        credentialsRepository
            .guid
            .zip(sessionTokenRepository.sessionToken) {
                (guid: $0, sessionToken: $1)
            }
            .flatMap { credentials -> AnyPublisher<(guid: String, sessionToken: String), SMSServiceError> in
                guard let guid = credentials.guid else {
                    return .failure(.missingCredentials(.guid))
                }
                guard let sessionToken = credentials.sessionToken else {
                    return .failure(.missingCredentials(.sessionToken))
                }
                return .just((guid, sessionToken))
            }
            .flatMap { [smsRepository] credentials -> AnyPublisher<Void, SMSServiceError> in
                smsRepository.request(
                    sessionToken: credentials.sessionToken,
                    guid: credentials.guid
                )
            }
            .eraseToAnyPublisher()
    }
}
