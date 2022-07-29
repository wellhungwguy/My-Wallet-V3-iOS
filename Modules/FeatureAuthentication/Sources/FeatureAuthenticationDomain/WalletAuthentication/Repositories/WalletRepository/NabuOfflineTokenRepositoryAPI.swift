// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import WalletPayloadKit

public protocol NabuOfflineTokenRepositoryAPI: AnyObject {
    /// The lifetime token object (userId, token) for the nabu account. It will be used for generating session token for accessing various nabu related services
    var offlineToken: AnyPublisher<NabuOfflineToken, MissingCredentialsError> { get }

    /// The lifetime token object (userId, token) for the nabu account. This will produce a continuous stream of tokens for signing in and signing up, whenever the token changes or fails
    var offlineTokenPublisher: AnyPublisher<Result<NabuOfflineToken, MissingCredentialsError>, Never> { get }

    /// Sets the nabu lifetime token in the wallet repository
    /// - Parameters:
    ///   - offlinToken: lifetime token object
    /// - Returns: An `AnyPublisher` that returns Void on sucesss or `CredentialsWritingError` if failed
    func set(offlineToken: NabuOfflineToken) -> AnyPublisher<Void, CredentialWritingError>
}
