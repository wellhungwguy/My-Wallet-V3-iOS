// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

extension Dictionary where Key == String, Value == Any {

    public func json(options: JSONSerialization.WritingOptions = []) throws -> Data {
        try JSONSerialization.data(withJSONObject: self, options: options)
    }
}

extension Array where Element == Any {

    public func json(options: JSONSerialization.WritingOptions = []) throws -> Data {
        try JSONSerialization.data(withJSONObject: self, options: options)
    }
}

extension Dictionary {

    @inlinable public func compactMapKeys<T>(_ transform: (Key) -> T?) -> [T: Value] {
        reduce(into: [T: Value]()) { result, x in
            if let key = transform(x.key) {
                result[key] = x.value
            }
        }
    }

    @inlinable public func compactMapKeys<T>(_ keyPath: KeyPath<Key, T?>) -> [T: Value] {
        reduce(into: [T: Value]()) { result, x in
            if let key = x.key[keyPath: keyPath] {
                result[key] = x.value
            }
        }
    }
}
