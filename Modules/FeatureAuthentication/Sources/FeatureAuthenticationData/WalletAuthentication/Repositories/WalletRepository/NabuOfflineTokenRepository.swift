// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import FeatureAuthenticationDomain
import WalletPayloadKit

final class NabuOfflineTokenRepository: NabuOfflineTokenRepositoryAPI {

    let offlineToken: AnyPublisher<NabuOfflineToken, MissingCredentialsError>

    lazy var offlineTokenPublisher: AnyPublisher<
        Result<NabuOfflineToken, MissingCredentialsError>, Never
    > = offlineTokenSubject.eraseToAnyPublisher()

    let offlineTokenSubject: PassthroughSubject<
        Result<NabuOfflineToken, MissingCredentialsError>, Never
    >

    // This is set to the older WalletRepository API, soon to be removed
    private let walletRepository: WalletRepositoryAPI
    private let credentialsFetcher: AccountCredentialsFetcherAPI
    private let reactiveWallet: ReactiveWalletAPI
    private let nativeWalletEnabled: () -> AnyPublisher<Bool, Never>

    init(
        walletRepository: WalletRepositoryAPI,
        credentialsFetcher: AccountCredentialsFetcherAPI,
        reactiveWallet: ReactiveWalletAPI,
        nativeWalletEnabled: @escaping () -> AnyPublisher<Bool, Never>
    ) {
        self.walletRepository = walletRepository
        self.credentialsFetcher = credentialsFetcher
        self.reactiveWallet = reactiveWallet
        self.nativeWalletEnabled = nativeWalletEnabled

        let subject = PassthroughSubject<
            Result<NabuOfflineToken, MissingCredentialsError>, Never
        >()

        offlineToken = nativeWalletEnabled()
            .flatMap { isEnabled -> AnyPublisher<NabuOfflineToken, MissingCredentialsError> in
                guard isEnabled else {
                    return walletRepository.offlineToken
                }
                return reactiveWallet.waitUntilInitializedFirst
                    .first()
                    .flatMap { _ -> AnyPublisher<NabuOfflineToken, MissingCredentialsError> in
                        credentialsFetcher.fetchAccountCredentials(forceFetch: false)
                            .mapError { _ in MissingCredentialsError.offlineToken }
                            .map { credentials in
                                NabuOfflineToken(
                                    userId: credentials.nabuUserId,
                                    token: credentials.nabuLifetimeToken,
                                    exchangeUserId: credentials.exchangeUserId,
                                    exchangeOfflineToken: credentials.exchangeLifetimeToken
                                )
                            }
                            .eraseToAnyPublisher()
                    }
                    .eraseToAnyPublisher()
            }
            .handleEvents(
                receiveOutput: { token in
                    subject.send(.success(token))
                },
                receiveCompletion: { completion in
                    switch completion {
                    case .failure(let error):
                        subject.send(.failure(error))
                    case .finished:
                        break
                    }
                }
            )
            .eraseToAnyPublisher()

        offlineTokenSubject = subject
        offlineTokenPublisher = subject.eraseToAnyPublisher()
    }

    func set(offlineToken: NabuOfflineToken) -> AnyPublisher<Void, CredentialWritingError> {
        nativeWalletEnabled()
            .handleEvents(
                receiveSubscription: { [offlineTokenSubject] _ in
                    offlineTokenSubject.send(.success(offlineToken))
                }
            )
            .flatMap { [walletRepository, credentialsFetcher] isEnabled -> AnyPublisher<Void, CredentialWritingError> in
                guard isEnabled else {
                    return walletRepository.set(offlineToken: offlineToken)
                }
                return credentialsFetcher.store(
                    credentials: AccountCredentials(
                        nabuUserId: offlineToken.userId,
                        nabuLifetimeToken: offlineToken.token,
                        exchangeUserId: offlineToken.exchangeUserId,
                        exchangeLifetimeToken: offlineToken.exchangeOfflineToken
                    )
                )
                .mapError { _ in CredentialWritingError.offlineToken }
                .first()
                .mapToVoid()
                .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }
}
