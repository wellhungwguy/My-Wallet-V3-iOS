// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import Foundation
import SwiftExtensions

/// A wrapper for atomic access to a generic value.
///
/// Uses a concurrent `DispatchQueue` for thread-safety.
public final class Atomic<Value> {

    private let lock = UnfairLock()

    /// Atomic read access to the wrapped value.
    public var value: Value {
        lock.withLock { _value }
    }

    /// A publisher that emits the wrapped value whenever it updates.
    ///
    /// When subscribing to this publisher, the first value emitted will be the current wrapped value.
    public var publisher: AnyPublisher<Value, Never> {
        subject.eraseToAnyPublisher()
    }

    // MARK: - Private Properties

    /// The wrapped value.
    private var _value: Value

    /// The wrapped value subject.
    private let subject: CurrentValueSubject<Value, Never>

    /// Creates an atomic wrapper.
    ///
    /// - Parameter value: A value.
    public init(_ value: Value) {
        self._value = value
        self.subject = CurrentValueSubject(value)
    }

    // MARK: - Public Methods

    /// Atomically mutates the wrapped value.
    ///
    /// The `transform` closure should not perform any slow computation as it it blocks the current thread.
    ///
    /// - Parameters:
    ///   - transform: A transform closure, atomically mutating the wrapped value.
    ///   - current:   The current wrapped value, passed as an `inout` parameter to allow mutation.
    ///
    /// - Returns: The updated wrapped value.
    @discardableResult
    public func mutate(_ transform: (_ current: inout Value) -> Void) -> Value {
        let value = lock.withLock { () -> Value in
            transform(&_value)
            return _value
        }
        defer { subject.send(value) }
        return value
    }

    /// Atomically mutates the wrapped value.
    ///
    /// The `transform` closure should not perform any slow computation as it it blocks the current thread.
    ///
    /// - Parameters:
    ///   - transform: A transform closure, atomically mutating the wrapped value.
    ///   - current:   The current wrapped value, passed as an `inout` parameter to allow mutation.
    ///
    /// - Returns: The return value of the `transform` closure.
    public func mutateAndReturn<T>(_ transform: (_ current: inout Value) -> T) -> T {
        let (value, result) = lock.withLock {
            let t = transform(&_value)
            return (_value, t)
        }
        defer { subject.send(value) }
        return result
    }
}
