// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Embrace
import FirebaseCrashlytics
import Foundation
import ObservabilityKit
import ToolKit

extension LogMessageTracing {
    public static func live(
        loggers: [LogMessageServiceAPI]
    ) -> LogMessageServiceAPI {
        LogMessageTracing.service(
            loggers: loggers
        )
    }

    static func provideLoggers() -> [LogMessageServiceAPI] {
    #if DEBUG || INTERNAL_BUILD
        return [LocalLogMessaging()]
    #else
        return [EmbraceLogMessaging()]
    #endif
    }
}

final class LocalLogMessaging: LogMessageServiceAPI {
    func logError(message: String, properties: [String: String]?) {
        message.peek(as: .error)
        properties?.peek(as: .error)
    }

    func logError(error: Error, properties: [String: String]?) {
        error.localizedDescription.peek(as: .error)
        properties?.peek(as: .error)
    }

    func logWarning(message: String, properties: [String: String]?) {
        message.peek(as: .warning)
        properties?.peek(as: .warning)
    }

    func logInfo(message: String, properties: [String: String]?) {
        message.peek(as: .info)
        properties?.peek(as: .info)
    }
}

final class EmbraceLogMessaging: LogMessageServiceAPI {

    func logError(message: String, properties: [String: String]?) {
        Embrace.sharedInstance().logMessage(
            message,
            with: .error,
            properties: properties
        )
    }

    func logError(error: Error, properties: [String: String]?) {
        Embrace.sharedInstance().logHandledError(
            error,
            screenshot: false,
            properties: properties
        )
    }

    func logWarning(message: String, properties: [String: String]?) {
        Embrace.sharedInstance().logMessage(
            message,
            with: .warning,
            properties: properties
        )
    }

    func logInfo(message: String, properties: [String: String]?) {
        Embrace.sharedInstance().logMessage(
            message,
            with: .info,
            properties: properties
        )
    }
}
