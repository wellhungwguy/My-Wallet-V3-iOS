// Copyright © Blockchain Luxembourg S.A. All rights reserved.

@discardableResult
public func with<T>(
    _ value: T,
    _ yield: (T) throws -> Void
) rethrows -> T {
    try yield(value)
    return value
}

@discardableResult
public func with<T>(
    _ value: inout T,
    _ yield: (inout T) throws -> Void
) rethrows -> T {
    try yield(&value)
    return value
}

@discardableResult
public func with<Root, Value>(
    _ value: Root,
    at keyPath: WritableKeyPath<Root, Value>,
    _ yield: (inout Value) throws -> Void
) rethrows -> Root {
    var copy = value
    var o = copy[keyPath: keyPath]
    try yield(&o)
    copy[keyPath: keyPath] = o
    return copy
}

@discardableResult
public func with<Root, Value>(
    _ value: Root,
    at keyPath: WritableKeyPath<Root, Value?>,
    default defaultValue: Value,
    _ yield: (inout Value) throws -> Void
) rethrows -> Root {
    var copy = value
    var o = copy[keyPath: keyPath] ?? defaultValue
    try yield(&o)
    copy[keyPath: keyPath] = o
    return copy
}

@discardableResult
public func with<Root, Value>(
    _ value: inout Root,
    at keyPath: WritableKeyPath<Root, Value>,
    _ yield: (inout Value) throws -> Void
) rethrows -> Root {
    var o = value[keyPath: keyPath]
    try yield(&o)
    value[keyPath: keyPath] = o
    return value
}

@discardableResult
public func with<Root, Value>(
    _ value: inout Root,
    at keyPath: WritableKeyPath<Root, Value?>,
    default defaultValue: Value,
    _ yield: (inout Value) throws -> Void
) rethrows -> Root {
    var o = value[keyPath: keyPath] ?? defaultValue
    try yield(&o)
    value[keyPath: keyPath] = o
    return value
}
