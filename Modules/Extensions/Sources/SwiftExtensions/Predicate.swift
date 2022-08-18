// Copyright © Blockchain Luxembourg S.A. All rights reserved.

public func == <Root, Value: Equatable>(keyPath: KeyPath<Root, Value>, value: Value) -> (Root) -> Bool {
    return { $0[keyPath: keyPath] == value }
}

public func != <Root, Value: Equatable>(keyPath: KeyPath<Root, Value>, value: Value) -> (Root) -> Bool {
    return { $0[keyPath: keyPath] != value }
}

public func < <Root, Value: Comparable>(keyPath: KeyPath<Root, Value>, value: Value) -> (Root) -> Bool {
    return { $0[keyPath: keyPath] < value }
}

public func > <Root, Value: Comparable>(keyPath: KeyPath<Root, Value>, value: Value) -> (Root) -> Bool {
    return { $0[keyPath: keyPath] > value }
}

public func <= <Root, Value: Comparable>(keyPath: KeyPath<Root, Value>, value: Value) -> (Root) -> Bool {
    return { $0[keyPath: keyPath] <= value }
}

public func >= <Root, Value: Comparable>(keyPath: KeyPath<Root, Value>, value: Value) -> (Root) -> Bool {
    return { $0[keyPath: keyPath] >= value }
}

public func && <T>(lhs: @escaping @autoclosure () -> Bool, rhs: @escaping (T) -> Bool) -> (T) -> Bool {
    return { lhs() && rhs($0) }
}

public func || <T>(lhs: @escaping @autoclosure () -> Bool, rhs: @escaping (T) -> Bool) -> (T) -> Bool {
    return { lhs() || rhs($0) }
}

public func && <T>(lhs: @escaping (T) -> Bool, rhs: @escaping @autoclosure () -> Bool) -> (T) -> Bool {
    return { lhs($0) && rhs() }
}

public func || <T>(lhs: @escaping (T) -> Bool, rhs: @escaping @autoclosure () -> Bool) -> (T) -> Bool {
    return { lhs($0) || rhs() }
}

public func && <T>(lhs: @escaping (T) -> Bool, rhs: @escaping (T) -> Bool) -> (T) -> Bool {
    return { lhs($0) && rhs($0) }
}

public func || <T>(lhs: @escaping (T) -> Bool, rhs: @escaping (T) -> Bool) -> (T) -> Bool {
    return { lhs($0) || rhs($0) }
}
