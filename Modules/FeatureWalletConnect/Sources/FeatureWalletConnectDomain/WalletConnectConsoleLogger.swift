import Foundation
import WalletConnectSwift

public protocol WalletConnectConsoleLoggerAPI {
    func disableConsoleLogsForDebugBuilds()
}

class WalletConnectConsoleLogger: WalletConnectConsoleLoggerAPI {

    struct Nope: WalletConnectSwift.Logger {
        func log(_ message: String) { }
    }

    func disableConsoleLogsForDebugBuilds() {
        #if DEBUG
        WalletConnectSwift.LogService.shared = Nope()
        #endif
    }
}
