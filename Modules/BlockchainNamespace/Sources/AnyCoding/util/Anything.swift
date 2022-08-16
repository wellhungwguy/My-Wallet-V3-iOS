import Foundation

@dynamicMemberLookup
public struct Anything: Codable, Hashable, Equatable, CustomStringConvertible {

    public struct Error: Swift.Error, CustomStringConvertible {
        public let description: String
    }

    public private(set) var wrapped: Any
    public var thing: Any { wrapped }

    internal var __unwrapped: Any {
        (wrapped as? Anything)?.__unwrapped ?? wrapped
    }

    public init(_ any: Any) {
        switch any {
        case let thing as Anything:
            self = thing
        default:
            wrapped = any
        }
    }

    private var __subscript: Any? {
        get { wrapped }
        set { wrapped = newValue ?? NSNull() }
    }

    public subscript<T>(dynamicMember keyPath: KeyPath<Any?, T>) -> T? {
        __subscript[keyPath: keyPath]
    }

    public subscript<C: Collection>(path: C) -> Any? where C.Element == CodingKey {
        get { __subscript[path] }
        set { __subscript[path] = newValue }
    }

    public func hash(into hasher: inout Hasher) {
        (wrapped as? AnyHashable).hash(into: &hasher)
    }

    public static func == (lhs: Self, rhs: Self) -> Bool {
        isEqual(lhs.__unwrapped, rhs.__unwrapped)
    }

    public init(from decoder: Decoder) throws {
        switch decoder {
        case let decoder as AnyDecoderProtocol:
            func ƒ(_ any: Any) throws -> Any {
                switch try decoder.convert(any, to: Any.self) ?? any {
                case let array as [Any]:
                    return try array.enumerated().map { o -> Any in
                        decoder.codingPath.append(AnyCodingKey(o.offset))
                        defer { decoder.codingPath.removeLast() }
                        return try ƒ(o.element)
                    }
                case let dictionary as [String: Any]:
                    return try Dictionary(uniqueKeysWithValues: dictionary.map { o -> (String, Any) in
                        decoder.codingPath.append(AnyCodingKey(o.key))
                        defer { decoder.codingPath.removeLast() }
                        return try (o.key, ƒ(o.value))
                    })
                case let fragment:
                    return fragment
                }
            }
            self = try .init(ƒ(decoder.value))
        default:
            throw Error(
                description: """
                Anything can only be decoded with
                AnyDecoderProtocol; got: \(decoder)
                """
            )
        }
    }

    public func encode(to encoder: Encoder) throws {
        switch encoder {
        case let encoder as AnyEncoderProtocol:
            func ƒ(_ any: Any) throws -> Any {
                if let o = try encoder.convert(any) { return o }
                switch any {
                case let array as [Any]:
                    return try array.map(ƒ)
                case let dictionary as [String: Any]:
                    return try dictionary.mapValues(ƒ)
                case let fragment:
                    return fragment
                }
            }
            encoder.value = try ƒ(wrapped)
        default:
            throw Error(
                description: """
                Anything can currently only be encoded with a
                AnyEncoderProtocol; got: \(encoder)
                """
            )
        }
    }

    public var description: String {
        String(describing: __unwrapped)
    }
}

extension Anything: ExpressibleByNilLiteral {
    public init(nilLiteral: ()) {
        self.init(NSNull())
    }
}

extension Anything: ExpressibleByArrayLiteral {
    public init(arrayLiteral elements: Any...) {
        self.init(elements)
    }
}

extension Anything: ExpressibleByDictionaryLiteral {
    public init(dictionaryLiteral elements: (String, Any)...) {
        self.init([String: Any].init(elements, uniquingKeysWith: { $1 }))
    }
}

extension Anything: ExpressibleByFloatLiteral {
    public init(floatLiteral value: Double) {
        self.init(value)
    }
}

extension Anything: ExpressibleByIntegerLiteral {
    public init(integerLiteral value: Int) {
        self.init(value)
    }
}

extension Anything: ExpressibleByStringLiteral {
    public init(stringLiteral value: String) {
        self.init(value)
    }
}

extension Anything: ExpressibleByBooleanLiteral {
    public init(booleanLiteral value: Bool) {
        self.init(value)
    }
}

extension Anything: ExpressibleByStringInterpolation {
    public init(stringInterpolation: DefaultStringInterpolation) {
        self.init(stringInterpolation.description)
    }
}

public struct CodableVoid: Codable, Equatable, Hashable {
    public init() {}
}
