// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import FeatureAuthenticationDomain
import WalletPayloadKit

final class MockNabuOfflineTokenRepository: NabuOfflineTokenRepositoryAPI {
    var expectedUserId: String?
    var expectedToken: String?
    var expectedOfflineToken: Result<NabuOfflineToken, MissingCredentialsError>! = .failure(.offlineToken)

    /// The lifetime token object (userId, token) for the nabu account. It will be used for generating session token for accessing various nabu related services
    var offlineToken: AnyPublisher<NabuOfflineToken, MissingCredentialsError> {
        expectedOfflineToken.publisher.eraseToAnyPublisher()
    }

    /// The lifetime token object (userId, token) for the nabu account. It will be used for generating session token for accessing various nabu related services
    var offlineTokenPublisher: AnyPublisher<Result<NabuOfflineToken, MissingCredentialsError>, Never> {
        Just(expectedOfflineToken).eraseToAnyPublisher()
    }

    /// Sets the nabu lifetime token in the wallet repository
    /// - Parameters:
    ///   - offlinToken: lifetime token object
    /// - Returns: An `AnyPublisher` that returns Void on sucesss or `CredentialsWritingError` if failed
    func set(offlineToken: NabuOfflineToken) -> AnyPublisher<Void, CredentialWritingError> {
        expectedOfflineToken = .success(offlineToken)
        return .just(())
    }
}
