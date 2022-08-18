// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine

@dynamicMemberLookup
public class Reference<T> {

    public let valueDidChange$ = PassthroughSubject<T, Never>()
    public var value: T {
        didSet { valueDidChange$.send(value) }
    }

    public init(_ value: T) {
        self.value = value
    }

    public init(_ value: inout T) {
        self.value = value
    }

    public subscript<Value>(dynamicMember keyPath: KeyPath<T, Value>) -> Value {
        value[keyPath: keyPath]
    }

    public subscript<Value>(dynamicMember keyPath: WritableKeyPath<T, Value>) -> Value {
        get {
            value[keyPath: keyPath]
        }
        set {
            value[keyPath: keyPath] = newValue
        }
    }
}

extension Reference: Equatable where T: Equatable {

    public static func == (lhs: Reference<T>, rhs: Reference<T>) -> Bool {
        lhs.value == rhs.value
    }
}

extension Reference: Hashable where T: Hashable {

    public func hash(into hasher: inout Hasher) {
        value.hash(into: &hasher)
    }
}

public class Weak<T> where T: AnyObject {

    public weak var value: T?

    public init(_ value: T?) {
        self.value = value
    }
}
