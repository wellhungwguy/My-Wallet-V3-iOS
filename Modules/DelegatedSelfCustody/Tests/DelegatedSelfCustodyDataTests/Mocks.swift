// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
@testable import DelegatedSelfCustodyData
import DelegatedSelfCustodyDomain
import Errors
import MoneyKit

final class GuidServiceMock: DelegatedCustodyGuidServiceAPI {
    var result: Result<String?, Never>!
    var guid: AnyPublisher<String?, Never> {
        result.publisher.eraseToAnyPublisher()
    }
}

final class SharedKeyServiceMock: DelegatedCustodySharedKeyServiceAPI {
    var result: Result<String?, Never>!
    var sharedKey: AnyPublisher<String?, Never> {
        result.publisher.eraseToAnyPublisher()
    }
}

final class AccountRepositoryMock: AccountRepositoryAPI {
    var result: Result<[Account], Error>!
    var accounts: AnyPublisher<[Account], Error> {
        result.publisher.eraseToAnyPublisher()
    }

    var delegatedCustodyAccounts: AnyPublisher<[DelegatedCustodyAccount], Error> {
        result
            .publisher
            .map { accounts -> [DelegatedCustodyAccount] in
                accounts
            }
            .eraseToAnyPublisher()
    }
}

final class SubscriptionsStateServiceMock: SubscriptionsStateServiceAPI {
    var result: Result<Bool, Never>!
    var isValid: AnyPublisher<Bool, Never> {
        result.publisher.eraseToAnyPublisher()
    }

    var recordSubscriptionParamsAccounts: [String]!
    func recordSubscription(accounts: [String]) -> AnyPublisher<Void, Never> {
        recordSubscriptionParamsAccounts = accounts
        return .just(())
    }
}

final class AuthenticationDataRepositoryMock: AuthenticationDataRepositoryAPI {
    var initialAuthenticationDataResult: Result<(guid: String, sharedKeyHash: String), Error>!
    var initialAuthenticationData: AnyPublisher<(guid: String, sharedKeyHash: String), Error> {
        initialAuthenticationDataResult.publisher.eraseToAnyPublisher()
    }

    var authenticationDataResult: Result<(guidHash: String, sharedKeyHash: String), Error>!
    var authenticationData: AnyPublisher<(guidHash: String, sharedKeyHash: String), Error> {
        authenticationDataResult.publisher.eraseToAnyPublisher()
    }
}

final class AuthenticationClientMock: AuthenticationClientAPI {
    var authResult: Result<Void, NetworkError>!
    var authParams: (guid: String, sharedKeyHash: String)!
    func auth(guid: String, sharedKeyHash: String) -> AnyPublisher<Void, NetworkError> {
        authParams = (guid: guid, sharedKeyHash: sharedKeyHash)
        return authResult.publisher.eraseToAnyPublisher()
    }
}

final class SubscriptionsClientMock: SubscriptionsClientAPI {
    var subscribeResult: Result<Void, NetworkError>!
    var subscribeParams: (guidHash: String, sharedKeyHash: String, subscriptions: [SubscriptionEntry])!
    func subscribe(
        guidHash: String,
        sharedKeyHash: String,
        subscriptions: [SubscriptionEntry]
    ) -> AnyPublisher<Void, NetworkError> {
        subscribeParams = (guidHash: guidHash, sharedKeyHash: sharedKeyHash, subscriptions: subscriptions)
        return subscribeResult.publisher.eraseToAnyPublisher()
    }

    var unsubscribeResult: Result<Void, NetworkError>!
    func unsubscribe(
        guidHash: String,
        sharedKeyHash: String,
        currency: String
    ) -> AnyPublisher<Void, NetworkError> {
        unsubscribeResult.publisher.eraseToAnyPublisher()
    }

    var subscriptionsResult: Result<SubscriptionsResponse, NetworkError>!
    func subscriptions(
        guidHash: String,
        sharedKeyHash: String
    ) -> AnyPublisher<SubscriptionsResponse, NetworkError> {
        subscriptionsResult.publisher.eraseToAnyPublisher()
    }
}
