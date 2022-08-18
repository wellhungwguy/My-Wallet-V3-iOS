// Copyright © Blockchain Luxembourg S.A. All rights reserved.

extension Sequence where Element: Equatable {

    @inlinable public func doesNotContain(_ element: Element) -> Bool {
        !contains(element)
    }
}

extension Sequence {

    @inlinable public func count(where predicate: (Element) -> Bool) -> Int {
        reduce(0) { predicate($1) ? $0 + 1 : $0 }
    }
}

extension Sequence {

    @inlinable public func none(_ predicate: (Element) throws -> Bool) rethrows -> Bool {
        for element in self where try predicate(element) { return false }
        return true
    }
}

extension Sequence {

    @inlinable public func map<T>(_ keyPath: KeyPath<Element, T>) -> [T] {
        map { $0[keyPath: keyPath] }
    }
}

extension Sequence where Iterator.Element: Hashable {

    @inlinable public var unique: [Iterator.Element] {
        var seen: Set<Iterator.Element> = []
        return filter { seen.insert($0).inserted }
    }
}

