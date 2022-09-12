// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import WalletPayloadKit

final class TwoFAWalletService: TwoFAWalletServiceAPI {

    // MARK: - Properties

    private let repository: TwoFAWalletRepositoryAPI
    private let walletRepo: WalletRepoAPI

    // MARK: - Setup

    init(
        repository: TwoFAWalletRepositoryAPI,
        walletRepo: WalletRepoAPI
    ) {
        self.repository = repository
        self.walletRepo = walletRepo
    }

    // MARK: - API

    func send(code: String) -> AnyPublisher<Void, TwoFAWalletServiceError> {
        // Trim whitespaces before verifying and sending
        let code = code.trimmingWhitespaces

        // Verify the code is not empty to save network call
        guard !code.isEmpty else {
            return .failure(.missingCode)
        }

        return walletRepo
            .credentials
            .first()
            .flatMap { credentials -> AnyPublisher<(guid: String, sessionToken: String), TwoFAWalletServiceError> in
                guard !credentials.guid.isEmpty else {
                    return .failure(.missingCredentials(.guid))
                }
                guard !credentials.sessionToken.isEmpty else {
                    return .failure(.missingCredentials(.sessionToken))
                }
                return .just((credentials.guid, credentials.sessionToken))
            }
            .flatMap { [repository] credentials -> AnyPublisher<WalletPayloadWrapper, TwoFAWalletServiceError> in
                repository.send(
                    guid: credentials.guid,
                    sessionToken: credentials.sessionToken,
                    code: code
                )
            }
            .flatMap { [walletRepo] rawPayload -> AnyPublisher<Void, TwoFAWalletServiceError> in
                // When 2FA is authenticated only the inner payload wrapper will be returned
                walletRepo
                    .set(keyPath: \.walletPayload.payloadWrapper, value: rawPayload)
                    .get()
                    .mapToVoid()
                    .mapError()
                    .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }
}
