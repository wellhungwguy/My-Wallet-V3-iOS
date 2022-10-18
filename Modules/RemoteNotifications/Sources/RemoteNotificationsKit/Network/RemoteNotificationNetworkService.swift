// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import FeatureAuthenticationDomain
import Foundation
import NetworkKit

/// Remote notification network service
final class RemoteNotificationNetworkService {

    // MARK: - Types

    private struct RegistrationResponseData: Decodable {
        let success: Bool
    }

    // MARK: - Properties

    private let pushNotificationsUrl: String
    private let networkAdapter: NetworkAdapterAPI

    // MARK: - Setup

    init(
        pushNotificationsUrl: String,
        networkAdapter: NetworkAdapterAPI
    ) {
        self.pushNotificationsUrl = pushNotificationsUrl
        self.networkAdapter = networkAdapter
    }
}

// MARK: - RemoteNotificationNetworkServicing

extension RemoteNotificationNetworkService: RemoteNotificationNetworkServicing {

    func register(
        with token: String,
        sharedKeyProvider: SharedKeyRepositoryAPI,
        guidProvider: GuidRepositoryAPI
    ) -> AnyPublisher<Void, PushNotificationError> {
        registrationRequest(
            with: token,
            sharedKeyProvider: sharedKeyProvider,
            guidProvider: guidProvider
        )
        .flatMap { [networkAdapter] request
            -> AnyPublisher<RegistrationResponseData, PushNotificationError> in
            networkAdapter
                .perform(request: request)
                .replaceError(with: PushNotificationError.registrationFailure)
        }
        .flatMap { response -> AnyPublisher<Void, PushNotificationError> in
            guard response.success else {
                return .failure(PushNotificationError.registrationFailure)
            }
            return .just(())
        }
        .eraseToAnyPublisher()
    }

    private func registrationRequest(
        with token: String,
        sharedKeyProvider: SharedKeyRepositoryAPI,
        guidProvider: GuidRepositoryAPI
    ) -> AnyPublisher<NetworkRequest, PushNotificationError> {
        let sharedKey = sharedKeyProvider.sharedKey
            .flatMap { sharedKey -> AnyPublisher<String, PushNotificationError> in
                guard let sharedKey else {
                    return .failure(PushNotificationError.missingCredentials)
                }
                guard !sharedKey.isEmpty else {
                    return .failure(PushNotificationError.emptyCredentials)
                }
                return .just(sharedKey)
            }
        let guid = guidProvider.guid
            .flatMap { guid -> AnyPublisher<String, PushNotificationError> in
                guard let guid else {
                    return .failure(PushNotificationError.missingCredentials)
                }
                guard !guid.isEmpty else {
                    return .failure(PushNotificationError.emptyCredentials)
                }
                return .just(guid)
            }

        return sharedKey.zip(guid)
            .map { sharedKey, guid in
                try? RemoteNotificationTokenQueryParametersBuilder(
                    guid: guid,
                    sharedKey: sharedKey,
                    token: token
                )
            }
            .onNil(PushNotificationError.emptyCredentials)
            .map(\.parameters)
            .onNil(PushNotificationError.couldNotBuildRequestBody)
            .map { [pushNotificationsUrl] parameters in
                NetworkRequest(
                    endpoint: URL(string: pushNotificationsUrl)!,
                    method: .post,
                    body: parameters,
                    contentType: .formUrlEncoded
                )
            }
            .eraseToAnyPublisher()
    }
}
