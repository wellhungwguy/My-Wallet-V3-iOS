// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

extension DispatchTimeInterval {

    public var timeInterval: TimeInterval {
        switch self {
        case .never:
            return TimeInterval(0)
        case .seconds(let value):
            return TimeInterval(value)
        case .milliseconds(let value):
            return TimeInterval(value) * 0.001
        case .microseconds(let value):
            return TimeInterval(value) * 0.000001
        case .nanoseconds(let value):
            return TimeInterval(value) * 0.000000001
        @unknown default:
            assertionFailure("Unknown case in \(My.self)")
            return TimeInterval(0)
        }
    }

    public static func minutes(_ value: Int) -> DispatchTimeInterval {
        .seconds(value * 60)
    }
}
