// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import CryptoSwift
import DelegatedSelfCustodyDomain
import Foundation

protocol AuthenticationDataRepositoryAPI {

    /// Streams authentication data to be used on the initial auth call.
    var initialAuthenticationData: AnyPublisher<(guid: String, sharedKeyHash: String), Error> { get }

    /// Streams authentication data to be used on endpoint calls.
    var authenticationData: AnyPublisher<(guidHash: String, sharedKeyHash: String), Error> { get }
}

enum AuthenticationDataRepositoryError: Error {
    case missingGUID
    case missingSharedKey
}

final class AuthenticationDataRepository: AuthenticationDataRepositoryAPI {

    private let guidService: DelegatedCustodyGuidServiceAPI
    private let sharedKeyService: DelegatedCustodySharedKeyServiceAPI

    init(
        guidService: DelegatedCustodyGuidServiceAPI,
        sharedKeyService: DelegatedCustodySharedKeyServiceAPI
    ) {
        self.guidService = guidService
        self.sharedKeyService = sharedKeyService
    }

    var initialAuthenticationData: AnyPublisher<(guid: String, sharedKeyHash: String), Error> {
        guid.zip(sharedKeyHash)
            .map { ($0, $1) }
            .eraseError()
            .eraseToAnyPublisher()
    }

    var authenticationData: AnyPublisher<(guidHash: String, sharedKeyHash: String), Error> {
        guidHash.zip(sharedKeyHash)
            .map { ($0, $1) }
            .eraseError()
            .eraseToAnyPublisher()
    }

    private var guid: AnyPublisher<String, AuthenticationDataRepositoryError> {
        guidService.guid
            .setFailureType(to: AuthenticationDataRepositoryError.self)
            .onNil(AuthenticationDataRepositoryError.missingGUID)
            .eraseToAnyPublisher()
    }

    private var sharedKey: AnyPublisher<String, AuthenticationDataRepositoryError> {
        sharedKeyService.sharedKey
            .setFailureType(to: AuthenticationDataRepositoryError.self)
            .onNil(AuthenticationDataRepositoryError.missingSharedKey)
            .eraseToAnyPublisher()
    }

    private var guidHash: AnyPublisher<String, AuthenticationDataRepositoryError> {
        guid
            .map(\.bytes)
            .map { sharedKeyBytes in
                Hash.sha2(sharedKeyBytes, variant: .sha256).toHexString()
            }
            .eraseToAnyPublisher()
    }

    private var sharedKeyHash: AnyPublisher<String, AuthenticationDataRepositoryError> {
        sharedKey
            .map(\.bytes)
            .map { sharedKeyBytes in
                Hash.sha2(sharedKeyBytes, variant: .sha256).toHexString()
            }
            .eraseToAnyPublisher()
    }
}
