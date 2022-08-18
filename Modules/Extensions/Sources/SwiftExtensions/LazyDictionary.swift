// Copyright © Blockchain Luxembourg S.A. All rights reserved.

public class LazyDictionary<Key, Value> where Key: Hashable {

    public private(set) var dictionary: [Key: Value]
    private var valueForKey: (Key) -> Value

    public init(
        _ dictionary: [Key: Value] = [:],
        valueForKey ƒ: @escaping (Key) -> Value
    ) {
        self.dictionary = dictionary
        valueForKey = ƒ
    }

    public convenience init(
        _ dictionary: [Key: Value] = [:],
        valueForKey ƒ: @escaping @autoclosure () -> Value
    ) {
        self.init(dictionary) { _ in ƒ() }
    }
}

extension LazyDictionary {

    public subscript(key: Key) -> Value {
        get {
            guard let value = dictionary[key] else {
                let __default = valueForKey(key)
                dictionary[key] = __default
                return __default
            }
            return value
        }
        set { dictionary[key] = newValue }
    }

    public subscript() -> [Key: Value] {
        get { dictionary }
        set { dictionary = newValue }
    }
}

extension LazyDictionary: Equatable where Value: Equatable {

    public static func == (lhs: LazyDictionary, rhs: LazyDictionary) -> Bool {
        lhs.dictionary == rhs.dictionary
    }
}

extension LazyDictionary: Hashable where Value: Hashable {

    public func hash(into hasher: inout Hasher) {
        hasher.combine(dictionary)
    }
}

extension LazyDictionary: LazySequenceProtocol, LazyCollectionProtocol {}

extension LazyDictionary: Collection {

    public typealias Base = [Key: Value]

    public var startIndex: Base.Index {
        dictionary.startIndex
    }

    public var endIndex: Base.Index {
        dictionary.endIndex
    }

    public var indices: Base.Indices {
        dictionary.indices
    }

    public subscript(position: Base.Index) -> Base.Element {
        dictionary[position]
    }

    public func index(after i: Base.Index) -> Base.Index {
        dictionary.index(after: i)
    }

    public func index(_ i: Base.Index, offsetBy distance: Int) -> Base.Index {
        dictionary.index(i, offsetBy: distance)
    }

    public func index(_ i: Base.Index, offsetBy distance: Int, limitedBy limit: Base.Index) -> Base.Index? {
        dictionary.index(i, offsetBy: distance, limitedBy: limit)
    }

    public func formIndex(after i: inout Base.Index) {
        dictionary.formIndex(after: &i)
    }

    public func makeIterator() -> Base.Iterator {
        dictionary.makeIterator()
    }

    public func distance(from start: Base.Index, to end: Base.Index) -> Int {
        dictionary.distance(from: start, to: end)
    }

    public var count: Int {
        dictionary.count
    }
}
