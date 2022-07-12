// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

public struct Options: Equatable {
    public let pbkdf2Iterations: Int
    public let feePerKB: Int?
    public let html5Notifications: Bool
    public let logoutTime: Int

    static var `default` = Options(
        pbkdf2Iterations: 5000,
        feePerKB: 10000,
        html5Notifications: false,
        logoutTime: 600000
    )

    public init(
        pbkdf2Iterations: Int,
        feePerKB: Int?,
        html5Notifications: Bool,
        logoutTime: Int
    ) {
        self.pbkdf2Iterations = pbkdf2Iterations
        self.feePerKB = feePerKB
        self.html5Notifications = html5Notifications
        self.logoutTime = logoutTime
    }
}
