// Copyright © Blockchain Luxembourg S.A. All rights reserved.

/// A random number generator implementation which takes values from `sequence` and cycles back to the start
/// once the sequence stops producing values
public struct NonRandomNumberGenerator: RandomNumberGenerator {

    public let sequence: AnySequence<UInt64>
    private var iterator: AnyIterator<UInt64>

    public init<S: Sequence>(_ s: S) where S.Element == UInt64 {
        sequence = AnySequence(s)
        iterator = sequence.makeIterator()
    }

    public mutating func next() -> UInt64 {
        guard let next = iterator.next() else {
            iterator = sequence.makeIterator()
            return next()
        }
        return next
    }
}
