// Copyright © Blockchain Luxembourg S.A. All rights reserved.

@inline(__always) @inlinable public func == <Root, Value: Equatable>(keyPath: KeyPath<Root, Value>, value: Value) -> (Root) -> Bool {
    { $0[keyPath: keyPath] == value }
}

@inline(__always) @inlinable public func != <Root, Value: Equatable>(keyPath: KeyPath<Root, Value>, value: Value) -> (Root) -> Bool {
    { $0[keyPath: keyPath] != value }
}

@inline(__always) @inlinable public func < <Root, Value: Comparable>(keyPath: KeyPath<Root, Value>, value: Value) -> (Root) -> Bool {
    { $0[keyPath: keyPath] < value }
}

@inline(__always) @inlinable public func > <Root, Value: Comparable>(keyPath: KeyPath<Root, Value>, value: Value) -> (Root) -> Bool {
    { $0[keyPath: keyPath] > value }
}

@inline(__always) @inlinable public func <= <Root, Value: Comparable>(keyPath: KeyPath<Root, Value>, value: Value) -> (Root) -> Bool {
    { $0[keyPath: keyPath] <= value }
}

@inline(__always) @inlinable public func >= <Root, Value: Comparable>(keyPath: KeyPath<Root, Value>, value: Value) -> (Root) -> Bool {
    { $0[keyPath: keyPath] >= value }
}

@inline(__always) @inlinable public func && <T>(lhs: @escaping @autoclosure () -> Bool, rhs: @escaping (T) -> Bool) -> (T) -> Bool {
    { lhs() && rhs($0) }
}

@inline(__always) @inlinable public func || <T>(lhs: @escaping @autoclosure () -> Bool, rhs: @escaping (T) -> Bool) -> (T) -> Bool {
    { lhs() || rhs($0) }
}

@inline(__always) @inlinable public func && <T>(lhs: @escaping (T) -> Bool, rhs: @escaping @autoclosure () -> Bool) -> (T) -> Bool {
    { lhs($0) && rhs() }
}

@inline(__always) @inlinable public func || <T>(lhs: @escaping (T) -> Bool, rhs: @escaping @autoclosure () -> Bool) -> (T) -> Bool {
    { lhs($0) || rhs() }
}

@inline(__always) @inlinable public func && <T>(lhs: @escaping (T) -> Bool, rhs: @escaping (T) -> Bool) -> (T) -> Bool {
    { lhs($0) && rhs($0) }
}

@inline(__always) @inlinable public func || <T>(lhs: @escaping (T) -> Bool, rhs: @escaping (T) -> Bool) -> (T) -> Bool {
    { lhs($0) || rhs($0) }
}
