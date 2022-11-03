// Copyright © Blockchain Luxembourg S.A. All rights reserved.

extension Comparable {

    @inlinable public func clamped(to range: ClosedRange<Self>) -> Self {
        (self...self).clamped(to: range).lowerBound
    }

    @inlinable public func clamped(to range: PartialRangeFrom<Self>) -> Self {
        (self...self).clamped(to: range).lowerBound
    }

    @inlinable public func clamped(to range: PartialRangeUpTo<Self>) -> Self {
        (self..<self).clamped(to: range).lowerBound
    }

    @inlinable public func clamped(to range: PartialRangeThrough<Self>) -> Self {
        (self...self).clamped(to: range).lowerBound
    }
}

extension Comparable where Self: FloatingPoint {

    @inlinable public func clamped(to range: PartialRangeFrom<Self>) -> Self {
        (self...self).clamped(to: range.lowerBound...(.greatestFiniteMagnitude)).lowerBound
    }

    @inlinable public func clamped(to range: PartialRangeUpTo<Self>) -> Self {
        (self...self).clamped(to: -(.greatestFiniteMagnitude)...(range.upperBound - 1)).lowerBound
    }

    @inlinable public func clamped(to range: PartialRangeThrough<Self>) -> Self {
        (self...self).clamped(to: -(.greatestFiniteMagnitude)...range.upperBound).lowerBound
    }
}

@inlinable public func min<T>(_ a: T, _ b: T, by: (T) -> some Comparable) -> T {
    by(a) < by(b) ? a : b
}

@inlinable public func max<T>(_ a: T, _ b: T, by: (T) -> some Comparable) -> T {
    by(a) >= by(b) ? a : b
}

extension BinaryInteger {

    @inlinable public func clamped(to range: Range<Self>) -> Self {
        (self...self).clamped(to: range.lowerBound...range.upperBound - 1).lowerBound
    }
}

extension ClosedRange {
    public init(between: Bound, and: Bound) {
        self = between < and ? between...and : and...between
    }
}

extension ClosedRange {

    @inlinable public func clamped(to range: PartialRangeFrom<Bound>) -> Self {
        clamped(to: range.lowerBound...Swift.max(upperBound, range.lowerBound))
    }

    @inlinable public func clamped(to range: PartialRangeThrough<Bound>) -> Self {
        clamped(to: Swift.min(lowerBound, range.upperBound)...range.upperBound)
    }
}

extension Range {

    @inlinable public func clamped(to range: PartialRangeUpTo<Bound>) -> Self {
        clamped(to: Swift.min(lowerBound, range.upperBound)..<range.upperBound)
    }
}
