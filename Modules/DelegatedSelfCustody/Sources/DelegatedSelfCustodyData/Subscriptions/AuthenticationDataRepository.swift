// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import CryptoSwift
import DelegatedSelfCustodyDomain
import Foundation

typealias InitialAuthenticationDataPayload = (guid: String, sharedKeyHash: String)
typealias AuthenticationDataPayload = (guidHash: String, sharedKeyHash: String)

protocol AuthenticationDataRepositoryAPI {

    /// Streams authentication data to be used on the initial auth call.
    var initialAuthenticationData: AnyPublisher<InitialAuthenticationDataPayload, AuthenticationDataRepositoryError> { get }

    /// Streams authentication data to be used on endpoint calls.
    var authenticationData: AnyPublisher<AuthenticationDataPayload, AuthenticationDataRepositoryError> { get }
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

    var initialAuthenticationData: AnyPublisher<InitialAuthenticationDataPayload, AuthenticationDataRepositoryError> {
        guid.zip(sharedKeyHash)
            .map { ($0, $1) }
            .eraseToAnyPublisher()
    }

    var authenticationData: AnyPublisher<AuthenticationDataPayload, AuthenticationDataRepositoryError> {
        guidHash.zip(sharedKeyHash)
            .map { ($0, $1) }
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
