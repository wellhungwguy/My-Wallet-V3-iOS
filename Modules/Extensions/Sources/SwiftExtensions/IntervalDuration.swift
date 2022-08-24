// Copyright © Blockchain Luxembourg S.A. All rights reserved.
// swiftformat:disable spaceAroundOperators

import Foundation

public struct IntervalDuration {

    let function: (Int) -> TimeInterval

    public init(_ function: @escaping (Int) -> TimeInterval) {
        self.function = function
    }

    public func callAsFunction(_ n: Int) -> TimeInterval { function(n) }
}

extension IntervalDuration {

    public static var zero: Self { .init(.never) }

    public static func constant(_ time: DispatchTimeInterval) -> Self {
        .init(time)
    }

    public static func exponential<R: RandomNumberGenerator>(
        unit: TimeInterval = 0.5,
        using randomNumberGenerator: inout R
    ) -> Self {
        let box = Reference(&randomNumberGenerator)
        return .init { n in
            TimeInterval.random(
                in: unit ... unit * pow(2, TimeInterval(n - 1)),
                using: &box.value
            )
        }
    }
}

extension IntervalDuration {

    public init(_ value: TimeInterval) {
        self.init { _ in value }
    }

    public init(_ value: DispatchTimeInterval) {
        self.init { _ in value.timeInterval }
    }
}
