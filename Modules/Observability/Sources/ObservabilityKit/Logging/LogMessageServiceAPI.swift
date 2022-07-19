// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation
import ToolKit

public protocol LogMessageServiceAPI {
    /// Logs an `Error`
    /// - Parameters:
    ///   - error: A `Error` value
    ///   - properties: An optional `Dictionary<String, String>` for more context
    func logError(error: Error, properties: [String: String]?)

    /// Logs an Error message
    /// - Parameters:
    ///   - message: A `String` value for the log message
    ///   - properties: An optional `Dictionary<String, String>` for more context
    func logError(message: String, properties: [String: String]?)

    /// - Parameters:
    ///   - message: A `String` value for the log message
    ///   - properties: An optional `Dictionary<String, String>` for more context
    func logWarning(message: String, properties: [String: String]?)

    /// Logs a info message
    /// - Parameters:
    ///   - message: A `String` value for the log message
    ///   - properties: An optional `Dictionary<String, String>` for more context
    func logInfo(message: String, properties: [String: String]?)
}

extension LogMessageServiceAPI {
    public func logError(error: Error) {
        logError(error: error, properties: nil)
    }

    public func logError(message: String) {
        logError(message: message, properties: nil)
    }

    public func logWarning(message: String) {
        logWarning(message: message, properties: nil)
    }

    public func logInfo(message: String) {
        logInfo(message: message, properties: nil)
    }
}
