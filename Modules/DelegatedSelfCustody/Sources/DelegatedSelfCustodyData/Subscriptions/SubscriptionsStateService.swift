// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainNamespace
import Combine

protocol SubscriptionsStateServiceAPI {

    /// Checks if authentication and subscription state are valid and up to date.
    var isValid: AnyPublisher<Bool, Never> { get }

    func recordSubscription(accounts: [String]) -> AnyPublisher<Void, Never>
}

final class SubscriptionsStateService: SubscriptionsStateServiceAPI {

    static let namespaceKey = blockchain.app.configuration.pubkey.service.auth

    private let accountRepository: AccountRepositoryAPI
    private let app: AppProtocol

    init(
        accountRepository: AccountRepositoryAPI,
        app: AppProtocol
    ) {
        self.accountRepository = accountRepository
        self.app = app
    }

    /// Checks if authentication and subscription state are valid and up to date.
    var isValid: AnyPublisher<Bool, Never> {
        currentlySubscribedAccounts
            .zip(activeAccounts)
            .map { currentlySubscribedAccount, activeAccounts in
                guard activeAccounts.isNotEmpty else {
                    return true
                }
                return activeAccounts.isSubset(of: currentlySubscribedAccount)
            }
            .eraseToAnyPublisher()
    }

    private var currentlySubscribedAccounts: AnyPublisher<Set<String>, Never> {
        Deferred { [app] in
            app
                .publisher(for: Self.namespaceKey, as: [String].self)
                .prefix(1)
                .map(\.value)
                .replaceNil(with: [])
                .map(Set.init)
                .eraseToAnyPublisher()
        }
        .eraseToAnyPublisher()
    }

    private var activeAccounts: AnyPublisher<Set<String>, Never> {
        accountRepository
            .accounts()
            .replaceError(with: [])
            .map { $0.map(\.coin.code) }
            .map(Set.init)
            .eraseToAnyPublisher()
    }

    func recordSubscription(accounts: [String]) -> AnyPublisher<Void, Never> {
        let accounts: [String] = accounts.unique
        return Deferred { [app] in
            Future { [app] promise in
                app.state.set(Self.namespaceKey, to: accounts)
                promise(.success(()))
            }
        }
        .eraseToAnyPublisher()
    }
}
