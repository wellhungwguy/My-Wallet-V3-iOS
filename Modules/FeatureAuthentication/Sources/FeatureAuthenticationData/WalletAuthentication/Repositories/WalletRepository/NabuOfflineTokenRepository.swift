// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import FeatureAuthenticationDomain
import WalletPayloadKit

final class NabuOfflineTokenRepository: NabuOfflineTokenRepositoryAPI {

    let offlineToken: AnyPublisher<NabuOfflineToken, MissingCredentialsError>

    let offlineTokenPublisher: AnyPublisher<Result<NabuOfflineToken, MissingCredentialsError>, Never>

    private let offlineTokenSubject: PassthroughSubject<Result<NabuOfflineToken, MissingCredentialsError>, Never>

    private let credentialsFetcher: AccountCredentialsFetcherAPI
    private let reactiveWallet: ReactiveWalletAPI

    init(
        credentialsFetcher: AccountCredentialsFetcherAPI,
        reactiveWallet: ReactiveWalletAPI
    ) {
        self.credentialsFetcher = credentialsFetcher
        self.reactiveWallet = reactiveWallet

        let subject = PassthroughSubject<Result<NabuOfflineToken, MissingCredentialsError>, Never>()

        self.offlineToken = Deferred { [reactiveWallet, credentialsFetcher] in
            reactiveWallet.waitUntilInitializedFirst
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

        self.offlineTokenSubject = subject
        self.offlineTokenPublisher = subject.eraseToAnyPublisher()
    }

    func set(offlineToken: NabuOfflineToken) -> AnyPublisher<Void, CredentialWritingError> {
        credentialsFetcher.store(
            credentials: AccountCredentials(
                nabuUserId: offlineToken.userId,
                nabuLifetimeToken: offlineToken.token,
                exchangeUserId: offlineToken.exchangeUserId,
                exchangeLifetimeToken: offlineToken.exchangeOfflineToken
            )
        )
        .handleEvents(
            receiveSubscription: { [offlineTokenSubject] _ in
                offlineTokenSubject.send(.success(offlineToken))
            }
        )
        .mapError { _ in CredentialWritingError.offlineToken }
        .first()
        .mapToVoid()
        .eraseToAnyPublisher()
    }
}
