// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation
import ToolKit

public enum LogMessageTracing {

    /// Provide the log message service
    /// - Parameter loggers: An array of `LogMessageServiceAPI`
    /// - Returns: `LogMessageServiceAPI`
    public static func service(
        loggers: [LogMessageServiceAPI]
    ) -> LogMessageServiceAPI {
        LogMessageService(
            loggers: loggers
        )
    }

    public static let noop: LogMessageServiceAPI = LogMessageService(loggers: [])
}
