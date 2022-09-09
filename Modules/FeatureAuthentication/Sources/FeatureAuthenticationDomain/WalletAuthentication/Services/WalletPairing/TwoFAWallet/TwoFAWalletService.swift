// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import WalletPayloadKit

public final class TwoFAWalletService: TwoFAWalletServiceAPI {

    // MARK: - Type

    public typealias WalletRepositoryAPI = GuidRepositoryAPI & SessionTokenRepositoryAPI & PayloadRepositoryAPI

    // MARK: - Properties

    private let repository: TwoFAWalletRepositoryAPI
    private let walletRepository: WalletRepositoryAPI
    private let walletRepo: WalletRepoAPI
    private let nativeWalletFlagEnabled: () -> AnyPublisher<Bool, Never>

    // MARK: - Setup

    public init(
        repository: TwoFAWalletRepositoryAPI,
        walletRepository: WalletRepositoryAPI,
        walletRepo: WalletRepoAPI,
        nativeWalletFlagEnabled: @escaping () -> AnyPublisher<Bool, Never>
    ) {
        self.repository = repository
        self.walletRepository = walletRepository
        self.walletRepo = walletRepo
        self.nativeWalletFlagEnabled = nativeWalletFlagEnabled
    }

    // MARK: - API

    public func send(code: String) -> AnyPublisher<Void, TwoFAWalletServiceError> {
        // Trim whitespaces before verifying and sending
        let code = code.trimmingWhitespaces

        // Verify the code is not empty to save network call
        guard !code.isEmpty else {
            return .failure(.missingCode)
        }

        return nativeWalletFlagEnabled()
            .flatMap { [old_send, new_send] isEnabled -> AnyPublisher<Void, TwoFAWalletServiceError> in
                guard isEnabled else {
                    return old_send(code)
                }
                return new_send(code)
            }
            .eraseToAnyPublisher()
    }

    private func old_send(code: String) -> AnyPublisher<Void, TwoFAWalletServiceError> {
        walletRepository
            .guid
            .zip(walletRepository.sessionToken)
            .flatMap { credentials -> AnyPublisher<(guid: String, sessionToken: String), TwoFAWalletServiceError> in
                guard let guid = credentials.0 else {
                    return .failure(.missingCredentials(.guid))
                }
                guard let sessionToken = credentials.1 else {
                    return .failure(.missingCredentials(.sessionToken))
                }
                return .just((guid, sessionToken))
            }
            .flatMap { [repository] credentials -> AnyPublisher<WalletPayloadWrapper, TwoFAWalletServiceError> in
                repository.send(
                    guid: credentials.guid,
                    sessionToken: credentials.sessionToken,
                    code: code
                )
            }
            .flatMap { response -> AnyPublisher<String, TwoFAWalletServiceError> in
                guard let rawPayload = response.stringRepresentation, !rawPayload.isEmpty else {
                    return .failure(.missingPayload)
                }
                return .just(rawPayload)
            }
            .flatMap { [walletRepository] rawPayload -> AnyPublisher<Void, TwoFAWalletServiceError> in
                walletRepository
                    .set(payload: rawPayload)
                    .mapError()
            }
            .eraseToAnyPublisher()
    }

    private func new_send(code: String) -> AnyPublisher<Void, TwoFAWalletServiceError> {
        walletRepo
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
