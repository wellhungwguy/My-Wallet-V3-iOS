// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import UserNotifications

/// A protocol that provides custom APIs for various operations of UNUserNotificationCenter
public protocol UNUserNotificationCenterAPI: AnyObject {
    /// A delegate for handling incoming notifications and notification-related actions
    var delegate: UNUserNotificationCenterDelegate? { get set }
    /// Retrieve the notification settings from users
    /// - Parameters:
    ///   - completionHandler: an escaping closure that return the settings
    func getNotificationSettings(completionHandler: @escaping (UNNotificationSettings) -> Void)
    /// Request authorization for notifications from users
    /// - Parameters:
    ///   - options: the authorization options
    ///   - completionHandler: an escaping closure that returns success or
    ///                        failure (with error)
    func requestAuthorization(options: UNAuthorizationOptions, completionHandler: @escaping (Bool, Error?) -> Void)
    /// Retrieve the current authorization status from users
    /// - Parameters:
    ///   - completionHandler: an escaping closure that returns the status
    func getAuthorizationStatus(completionHandler: @escaping (UNAuthorizationStatus) -> Void)
}

extension UNUserNotificationCenter: UNUserNotificationCenterAPI {}

extension UNUserNotificationCenterAPI {
    public func getAuthorizationStatus(completionHandler: @escaping (UNAuthorizationStatus) -> Void) {
        getNotificationSettings { settings in
            completionHandler(settings.authorizationStatus)
        }
    }

    public func requestAuthorizationPublisher(options: UNAuthorizationOptions) -> AnyPublisher<Bool, Error> {
        Deferred { [requestAuthorization] in
            Future { [requestAuthorization] promise in
                requestAuthorization(options) { isGranted, error in
                    if let error {
                        promise(.failure(error))
                    } else {
                        promise(.success(isGranted))
                    }
                }
            }
        }
        .eraseToAnyPublisher()
    }
}
