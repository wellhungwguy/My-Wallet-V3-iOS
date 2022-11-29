public struct Pair<T, U> {

    public var left: T
    public var right: U

    public init(_ x: T, _ y: U) { (left, right) = (x, y) }
    public init(_ tuple: (T, U)) { (left, right) = tuple }

    @_disfavoredOverload public init(_ y: U, _ x: T) { (right, left) = (y, x) }
    @_disfavoredOverload public init(_ tuple: (U, T)) { (left, right) = (tuple.1, tuple.0) }

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
        left = try container.decode(T.self)
        right = try container.decode(U.self)
    }
}

extension Pair: Encodable where T: Encodable, U: Encodable {

    public func encode(to encoder: Encoder) throws {
        var container = encoder.unkeyedContainer()
        try container.encode(left)
        try container.encode(right)
    }
}
