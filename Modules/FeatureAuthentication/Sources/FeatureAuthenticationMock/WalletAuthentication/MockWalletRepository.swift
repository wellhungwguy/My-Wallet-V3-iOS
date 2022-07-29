// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
@testable import FeatureAuthenticationDomain
import ToolKit
import WalletPayloadKit

final class MockWalletRepository: WalletRepositoryAPI {

    var expectedSessionToken: String?
    var expectedAuthenticatorType: WalletAuthenticatorType = .standard
    var expectedGuid: String?
    var expectedPayload: String?
    var expectedSharedKey: String?
    var expectedPassword: String?
    var expectedSyncPubKeys = false
    var expectedOfflineToken: Result<NabuOfflineToken, MissingCredentialsError>!
    var expectedChangePassword: Result<Void, PasswordRepositoryError>!

    var guid: AnyPublisher<String?, Never> {
        .just(expectedGuid)
    }

    var sharedKey: AnyPublisher<String?, Never> {
        .just(expectedSharedKey)
    }

    var sessionToken: AnyPublisher<String?, Never> {
        .just(expectedSessionToken)
    }

    var authenticatorType: AnyPublisher<WalletAuthenticatorType, Never> {
        .just(expectedAuthenticatorType)
    }

    var password: AnyPublisher<String?, Never> {
        .just(expectedPassword)
    }

    var hasPassword: AnyPublisher<Bool, Never> {
        .just(true)
    }

    var payload: AnyPublisher<String?, Never> {
        .just(expectedPayload)
    }

    var offlineTokenPublisher: AnyPublisher<Result<NabuOfflineToken, MissingCredentialsError>, Never> {
        Just(expectedOfflineToken).eraseToAnyPublisher()
    }

    var offlineToken: AnyPublisher<NabuOfflineToken, MissingCredentialsError> {
        expectedOfflineToken.publisher.eraseToAnyPublisher()
    }

    func set(guid: String) -> AnyPublisher<Void, Never> {
        perform { [weak self] in
            self?.expectedGuid = guid
        }
    }

    func set(sharedKey: String) -> AnyPublisher<Void, Never> {
        perform { [weak self] in
            self?.expectedSharedKey = sharedKey
        }
    }

    func set(sessionToken: String) -> AnyPublisher<Void, Never> {
        perform { [weak self] in
            self?.expectedSessionToken = sessionToken
        }
    }

    func cleanSessionToken() -> AnyPublisher<Void, Never> {
        perform { [weak self] in
            self?.expectedSessionToken = nil
        }
    }

    func set(authenticatorType: WalletAuthenticatorType) -> AnyPublisher<Void, Never> {
        perform { [weak self] in
            self?.expectedAuthenticatorType = authenticatorType
        }
    }

    func set(password: String) -> AnyPublisher<Void, Never> {
        perform { [weak self] in
            self?.expectedPassword = password
        }
    }

    func changePassword(password: String) -> AnyPublisher<Void, PasswordRepositoryError> {
        expectedChangePassword
            .publisher
            .eraseToAnyPublisher()
    }

    func set(offlineToken: NabuOfflineToken) -> AnyPublisher<Void, CredentialWritingError> {
        perform { [weak self] in
            self?.expectedOfflineToken = .success(offlineToken)
        }
    }

    func set(syncPubKeys: Bool) -> AnyPublisher<Void, Never> {
        perform { [weak self] in
            self?.expectedSyncPubKeys = syncPubKeys
        }
    }

    func sync() -> AnyPublisher<Void, PasswordRepositoryError> {
        perform {}
    }

    func set(language: String) -> AnyPublisher<Void, Never> {
        .just(())
    }

    func set(payload: String) -> AnyPublisher<Void, Never> {
        perform { [weak self] in
            self?.expectedPayload = payload
        }
    }

    private func perform<E: Error>(_ operation: @escaping () -> Void) -> AnyPublisher<Void, E> {
        Deferred {
            Future { $0(.success(operation())) }
        }
        .eraseToAnyPublisher()
    }
}
