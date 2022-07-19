// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainNamespace
import Combine
import CryptoSwift
import DelegatedSelfCustodyDomain
import Foundation
import Localization

final class SubscriptionsService: DelegatedCustodySubscriptionsServiceAPI {

    private let accountRepository: AccountRepositoryAPI
    private let authClient: AuthenticationClientAPI
    private let authenticationDataRepository: AuthenticationDataRepositoryAPI
    private let subscriptionsClient: SubscriptionsClientAPI
    private let subscriptionsStateService: SubscriptionsStateServiceAPI

    init(
        accountRepository: AccountRepositoryAPI,
        authClient: AuthenticationClientAPI,
        authenticationDataRepository: AuthenticationDataRepositoryAPI,
        subscriptionsClient: SubscriptionsClientAPI,
        subscriptionsStateService: SubscriptionsStateServiceAPI
    ) {
        self.accountRepository = accountRepository
        self.authClient = authClient
        self.authenticationDataRepository = authenticationDataRepository
        self.subscriptionsClient = subscriptionsClient
        self.subscriptionsStateService = subscriptionsStateService
    }

    func subscribe() -> AnyPublisher<Void, Error> {
        subscriptionsStateService.isValid
            .flatMap { [authenticateAndSubscribeAccounts] isValid -> AnyPublisher<Void, Error> in
                guard !isValid else {
                    return .just(())
                }
                return authenticateAndSubscribeAccounts
            }
            .eraseToAnyPublisher()
    }

    private var authenticateAndSubscribeAccounts: AnyPublisher<Void, Error> {
        authenticate
            .flatMap { [subscribeAccounts] _ -> AnyPublisher<Void, Error> in
                subscribeAccounts
            }
            .eraseToAnyPublisher()
    }

    private var authenticate: AnyPublisher<Void, Error> {
        authenticationDataRepository.initialAuthenticationData
            .flatMap { [authClient] authenticationData -> AnyPublisher<Void, Error> in
                authClient.auth(
                    guid: authenticationData.guid,
                    sharedKeyHash: authenticationData.sharedKeyHash
                )
                .eraseError()
            }
            .eraseToAnyPublisher()
    }

    private var subscribeAccounts: AnyPublisher<Void, Error> {
        accounts
            .zip(authenticationDataRepository.authenticationData)
            .flatMap { [subscriptionsClient, subscriptionsStateService] accounts, authenticationData -> AnyPublisher<Void, Error> in
                subscriptionsClient.subscribe(
                    guidHash: authenticationData.guidHash,
                    sharedKeyHash: authenticationData.sharedKeyHash,
                    subscriptions: accounts
                )
                .eraseError()
                .flatMap { [subscriptionsStateService] _ -> AnyPublisher<Void, Error> in
                    subscriptionsStateService
                        .recordSubscription(accounts: accounts.map(\.currency))
                        .eraseError()
                }
                .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }

    private var accounts: AnyPublisher<[SubscriptionEntry], Error> {
        accountRepository
            .accounts
            .map { accounts -> [SubscriptionEntry] in
                accounts.map { account -> SubscriptionEntry in
                    SubscriptionEntry(
                        currency: account.coin.code,
                        account: .init(index: 0, name: LocalizationConstants.Account.myWallet),
                        pubkeys: [
                            .init(pubkey: account.publicKey.toHexString(), style: account.style, descriptor: 0)
                        ]
                    )
                }
            }
            .eraseToAnyPublisher()
    }
}
