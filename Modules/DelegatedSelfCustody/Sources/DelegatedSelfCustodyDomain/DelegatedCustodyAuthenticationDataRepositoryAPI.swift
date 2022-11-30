// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import Foundation

public typealias InitialAuthenticationDataPayload = (guid: String, sharedKeyHash: String)
public typealias AuthenticationDataPayload = (guidHash: String, sharedKeyHash: String)

public protocol DelegatedCustodyAuthenticationDataRepositoryAPI {

    /// Streams authentication data to be used on the initial auth call.
    var initialAuthenticationData: AnyPublisher<InitialAuthenticationDataPayload, AuthenticationDataRepositoryError> { get }

    /// Streams authentication data to be used on endpoint calls.
    var authenticationData: AnyPublisher<AuthenticationDataPayload, AuthenticationDataRepositoryError> { get }
}
