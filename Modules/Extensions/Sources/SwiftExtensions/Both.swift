public struct Pair<T, U> {

    public var left: T
    public var right: U

    public init(_ x: T, _ y: U) { (self.left, self.right) = (x, y) }
    public init(_ tuple: (T, U)) { (self.left, self.right) = tuple }

    @_disfavoredOverload public init(_ y: U, _ x: T) { (self.right, self.left) = (y, x) }
    @_disfavoredOverload public init(_ tuple: (U, T)) { (self.left, self.right) = (tuple.1, tuple.0) }

    public var tuple: (T, U) {
        get { (left, right) }
        set { (left, right) = newValue }
    }
}

extension Pair: Equatable where T: Equatable, U: Equatable {}
extension Pair: Hashable where T: Hashable, U: Hashable {}
extension Pair: Decodable where T: Decodable, U: Decodable {

    public init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()
        self.left = try container.decode(T.self)
        self.right = try container.decode(U.self)
    }
}

extension Pair: Encodable where T: Encodable, U: Encodable {

    public func encode(to encoder: Encoder) throws {
        var container = encoder.unkeyedContainer()
        try container.encode(left)
        try container.encode(right)
    }
}

extension Pair {

    public func mapLeft<A>(_ transform: (T) -> A) -> Pair<A, U> {
        .init(transform(left), right)
    }

    public func mapRight<A>(_ transform: (T) -> A) -> Pair<A, U> {
        .init(transform(left), right)
    }

    public func map<A, B>(_ transform: (T, U) -> (A, B)) -> Pair<A, B> {
        .init(transform(left, right))
    }

    public func flatMap<A, B>(_ transform: (T, U) -> Pair<A, B>) -> Pair<A, B> {
        transform(left, right)
    }
}
