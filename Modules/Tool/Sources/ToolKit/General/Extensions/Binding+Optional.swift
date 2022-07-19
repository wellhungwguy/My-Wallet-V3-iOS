// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import SwiftUI

extension Binding where Value: Equatable {

    @inlinable public func equals(
        _ value: Value,
        default defaultValue: Value
    ) -> Binding<Bool> {
        .init(
            get: { wrappedValue == value },
            set: { newValue in transaction(transaction).wrappedValue = newValue ? value : defaultValue }
        )
    }
}

extension Binding where Value: Equatable, Value: OptionalProtocol {

    @inlinable public func equals(
        _ value: Value,
        default defaultValue: Value = nil
    ) -> Binding<Bool> {
        .init(
            get: { wrappedValue == value },
            set: { newValue in transaction(transaction).wrappedValue = newValue ? value : defaultValue }
        )
    }

    @inlinable public func `if`(
        _ condition: @escaping (Value.Wrapped) -> Bool,
        default defaultValue: Bool = false
    ) -> Binding<Bool> {
        Binding<Bool>(
            get: { wrappedValue.wrapped.map(condition) ?? defaultValue },
            set: { newValue in
                guard !newValue else { return }
                transaction(transaction).wrappedValue = nil
            }
        )
    }
}

extension Binding where Value == Bool {

    @inlinable public func inverted() -> Binding {
        .init(
            get: { !wrappedValue },
            set: { newValue, txn in transaction(txn).wrappedValue = !newValue }
        )
    }
}

extension Binding {

    public func didSet(_ perform: @escaping (Value) -> Void) -> Self {
        .init(
            get: { wrappedValue },
            set: { newValue, transaction in
                self.transaction(transaction).wrappedValue = newValue
                perform(newValue)
            }
        )
    }

    public func transform<T>(
        get: @escaping (Value) -> T,
        set: @escaping (T) -> Value
    ) -> Binding<T> {
        .init(
            get: { get(wrappedValue) },
            set: { newValue, tx in
                transaction(tx).wrappedValue = set(newValue)
            }
        )
    }
}
