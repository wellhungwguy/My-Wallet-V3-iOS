// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

extension Dictionary {

    @inlinable public func mapKeys<A>(_ keyPath: KeyPath<Key, A>) -> [A: Value] {
        mapKeys { $0[keyPath: keyPath] }
    }

    @inlinable public func mapKeys<A>(_ transform: (Key) throws -> A) rethrows -> [A: Value] {
        try reduce(into: [:]) { a, e in try a[transform(e.key)] = e.value }
    }

    @inlinable public func mapKeysAndValues<A, B>(key: KeyPath<Key, A>, value: KeyPath<Value, B>) -> [A: B] {
        mapKeysAndValues(key: { $0[keyPath: key] }, value: { $0[keyPath: value] })
    }

    @inlinable public func mapKeysAndValues<A, B>(key: (Key) throws -> A, value: (Value) throws -> B) rethrows -> [A: B] {
        try reduce(into: [:]) { a, e in try a[key(e.key)] = value(e.value) }
    }

    @inlinable public func compactMapKeys<T>(_ keyPath: KeyPath<Key, T?>) -> [T: Value] {
        compactMapKeys { $0[keyPath: keyPath] }
    }

    @inlinable public func compactMapKeys<T>(_ transform: (Key) -> T?) -> [T: Value] {
        reduce(into: [T: Value]()) { result, x in
            if let key = transform(x.key) {
                result[key] = x.value
            }
        }
    }

    @inlinable public func compactMapValues<T>(_ keyPath: KeyPath<Value, T?>) -> [Key: T] {
        compactMapValues { $0[keyPath: keyPath] }
    }

    @inlinable public func compactMapValues<T>(_ transform: (Value) throws -> T?) rethrows -> [Key: T] {
        try reduce(into: [Key: T]()) { result, element in
            if let value = try transform(element.value) {
                result[element.key] = value
            }
        }
    }
}

public enum DictionaryMergeUniquingPolicy {
    case old, new
}

extension Dictionary {

    /// Merges the given dictionary into this dictionary. In case of duplicate keys, uses the value from the given dictionary.
    @inlinable public mutating func merge(
        _ other: Dictionary,
        uniquingKeysPolicy policy: DictionaryMergeUniquingPolicy = .new
    ) {
        merge(other) { lhs, rhs in policy == .new ? rhs : lhs }
    }

    /// Creates a dictionary by merging the given dictionary into this dictionary. In case of duplicate keys, uses the value from the given dictionary.
    @inlinable public func merging(
        _ other: Dictionary,
        uniquingKeysPolicy policy: DictionaryMergeUniquingPolicy = .new
    ) -> [Key: Value] {
        merging(other) { lhs, rhs in policy == .new ? rhs : lhs }
    }
}

extension Dictionary {

    @inlinable public static func + (lhs: Dictionary, rhs: Dictionary) -> Dictionary {
        lhs.merging(rhs, uniquingKeysWith: { $1 })
    }

    @inlinable public static func += (lhs: inout Dictionary, rhs: Dictionary) {
        lhs.merge(rhs, uniquingKeysWith: { $1 })
    }
}
