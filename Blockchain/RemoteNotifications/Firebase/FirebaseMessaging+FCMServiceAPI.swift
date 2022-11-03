// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import FirebaseMessaging
import RemoteNotificationsKit

protocol FirebaseCloudMessagingServiceAPI: RemoteNotificationTokenFetching {
    var apnsToken: Data? { get set }

    @discardableResult
    func appDidReceiveMessage(_ message: [AnyHashable: Any]) -> MessagingMessageInfo
    func subscribe(toTopic topic: String, completion: ((Error?) -> Void)?)
}

extension Messaging: FirebaseCloudMessagingServiceAPI {

    public func token(handler: @escaping (RemoteNotificationTokenFetchResult) -> Void) {
        token { token, error in
            if let error {
                handler(.failure(.external(error)))
            } else if let token {
                if token.isEmpty {
                    handler(.failure(.tokenIsEmpty))
                } else {
                    handler(.success(token))
                }
            } else {
                handler(.failure(.resultIsNil))
            }
        }
    }
}
