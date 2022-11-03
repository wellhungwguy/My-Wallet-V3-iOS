// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import FirebaseMessaging
import Foundation
import RemoteNotificationsKit

/// A class that is a gateway to external notification service functionality
final class ExternalNotificationServiceProvider: ExternalNotificationProviding {

    // MARK: - Properties

    var token: AnyPublisher<String, RemoteNotification.TokenFetchError> {
        Deferred { [messagingService] in
            Future { [messagingService] promise in
                messagingService.token { result in
                    switch result {
                    case .failure(let error):
                        promise(.failure(error))
                    case .success(let token):
                        promise(.success(token))
                    }
                }
            }
        }
        .subscribe(on: DispatchQueue.global())
        .eraseToAnyPublisher()
    }

    // MARK: - Private Properties

    private let messagingService: FirebaseCloudMessagingServiceAPI

    // MARK: - Init

    init(messagingService: FirebaseCloudMessagingServiceAPI = Messaging.messaging()) {
        self.messagingService = messagingService
    }

    // MARK: - Methods

    func subscribe(
        to topic: RemoteNotification.Topic
    ) -> AnyPublisher<Void, ExternalNotificationProviderError> {
        Deferred { [messagingService] in
            Future { [messagingService] promise in
                messagingService.subscribe(toTopic: topic.rawValue) { error in
                    if let error {
                        promise(.failure(.system(error)))
                    } else {
                        promise(.success(()))
                    }
                }
            }
        }
        .subscribe(on: DispatchQueue.global())
        .eraseToAnyPublisher()
    }

    func didReceiveNewApnsToken(token: Data) {
        messagingService.apnsToken = token
    }
}
