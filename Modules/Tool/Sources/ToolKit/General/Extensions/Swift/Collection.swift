// Copyright © Blockchain Luxembourg S.A. All rights reserved.

extension Collection {

    @inlinable public func filter<T>(_ type: T.Type) -> [T] {
        compactMap { $0 as? T }
    }

    @inlinable public func contains<T>(_ type: T.Type) -> Bool {
        contains(where: { $0 is T })
    }
}

extension BinaryInteger {

    @inlinable public func of<T>(_ value: @autoclosure () -> T) -> [T] {
        Array(repeating: value(), count: i)
    }

    @inlinable public func of<T>(_ value: () -> T) -> [T] {
        Array(repeating: value(), count: i)
    }
}

extension Collection where Element: Equatable {

    @inlinable public func sorted(like other: [Element]) -> [Element] {
        sorted { a, b -> Bool in
            guard let first = other.firstIndex(of: a) else { return false }
            guard let second = other.firstIndex(of: b) else { return true }
            return first < second
        }
    }
}

extension Collection {
    @inlinable public var isNotEmpty: Bool { !isEmpty }
}

extension Collection where Element: Hashable {
    @inlinable public var set: Set<Element> { Set(self) }
}

extension Collection {
    @inlinable public var array: [Element] { Array(self) }
}
