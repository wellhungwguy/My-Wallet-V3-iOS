// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainNamespace
import Combine
import Foundation
import ToolKit

final class LogMessageService: LogMessageServiceAPI {

    private let loggers: [LogMessageServiceAPI]

    init(
        loggers: [LogMessageServiceAPI]
    ) {
        self.loggers = loggers
    }

    // MARK: - Logging methods

    func logError(message: String, properties: [String: String]?) {
        for logger in loggers {
            logger.logError(message: message, properties: properties)
        }
    }

    func logError(error: Error, properties: [String: String]?) {
        for logger in loggers {
            logger.logError(error: error, properties: properties)
        }
    }

    func logInfo(message: String, properties: [String: String]?) {
        for logger in loggers {
            logger.logInfo(message: message, properties: properties)
        }
    }

    func logWarning(message: String, properties: [String: String]?) {
        for logger in loggers {
            logger.logWarning(message: message, properties: properties)
        }
    }
}
