// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

public protocol OptionalProtocol: ExpressibleByNilLiteral {
    associatedtype Wrapped

    var wrapped: Wrapped? { get }
    static var none: Self { get }

    static func some(_ newValue: Wrapped) -> Self
    func map<U>(_ f: (Wrapped) throws -> U) rethrows -> U?
    func flatMap<U>(_ f: (Wrapped) throws -> U?) rethrows -> U?
}

extension OptionalProtocol {
    public var isNil: Bool { wrapped == nil }
    public var isNotNil: Bool { wrapped != nil }
}

extension Optional: OptionalProtocol {
    public var wrapped: Wrapped? { self }
}

extension Optional {

    @discardableResult
    public func or<E>(throw error: @autoclosure () -> E) throws -> Wrapped where E: Error {
        guard let value = self else { throw error() }
        return value
    }

    public func or(default defaultValue: @autoclosure () -> Wrapped) -> Wrapped {
        guard let value = self else { return defaultValue() }
        return value
    }

    public func `as`<T>(_ type: T.Type) -> T? {
        wrapped as? T
    }

    public subscript<T>(_: T.Type = T.self) -> T? {
        wrapped as? T
    }
}

// Optional Assignment
infix operator ?=: AssignmentPrecedence

public func ?= <A>(l: inout A, r: A?) {
    if let r = r { l = r }
}

extension Optional {

    @inlinable public func map<T>(_ type: T.Type) -> T? { self as? T }
}

extension Collection {

    public var nilIfEmpty: Self? {
        isEmpty ? nil : self
    }
}

extension Optional where Wrapped: Collection {

    @inlinable public var isNilOrEmpty: Bool {
        switch self {
        case .none:
            return true
        case .some(let wrapped):
            return wrapped.isEmpty
        }
    }

    @inlinable public var isNotNilOrEmpty: Bool {
        !isNilOrEmpty
    }

    @inlinable public var nilIfEmpty: Optional {
        isNilOrEmpty ? nil : self
    }
}

extension Optional where Wrapped: Collection & ExpressibleByArrayLiteral {

    @inlinable public var emptyIfNil: Wrapped {
        switch self {
        case .none:
            return []
        case .some(let wrapped):
            return wrapped
        }
    }
}

extension Optional where Wrapped: Collection & ExpressibleByStringLiteral {

    @inlinable public var emptyIfNil: Wrapped {
        switch self {
        case .none:
            return ""
        case .some(let wrapped):
            return wrapped
        }
    }
}

extension Optional: CustomStringConvertible {

    public var description: String {
        switch self {
        case .none:
            return "nil \(Wrapped.self)"
        case .some(let wrapped):
            return "\(wrapped)"
        }
    }
}

public protocol OptionalCodingPropertyWrapper {
    associatedtype WrappedType: ExpressibleByNilLiteral
    var wrappedValue: WrappedType { get }
    init(wrappedValue: WrappedType)
}

extension KeyedDecodingContainer {

    public func decode<T>(
        _ type: T.Type,
        forKey key: KeyedDecodingContainer<K>.Key
    ) throws -> T where T: Decodable, T: OptionalCodingPropertyWrapper {
        (try? decodeIfPresent(T.self, forKey: key)) ?? T(wrappedValue: nil)
    }
}

extension KeyedEncodingContainer {

    public mutating func encode<T>(
        _ value: T,
        forKey key: KeyedEncodingContainer<K>.Key
    ) throws where T: Encodable, T: OptionalCodingPropertyWrapper {
        if case Optional<Any>.none = value.wrappedValue as Any { return }
        try encodeIfPresent(value, forKey: key)
    }
}

extension Optional where Wrapped: Swift.Codable {

    @propertyWrapper
    public struct Codable: Swift.Codable, OptionalCodingPropertyWrapper {

        public var wrappedValue: Wrapped?

        public init(wrappedValue: Wrapped?) {
            self.wrappedValue = wrappedValue
        }

        public init(from decoder: Decoder) throws {
            do {
                let container = try decoder.singleValueContainer()
                wrappedValue = try container.decode(Wrapped.self)
            } catch {
                wrappedValue = try? Wrapped(from: decoder)
            }
        }

        public func encode(to encoder: Encoder) throws {
            try? wrappedValue.encode(to: encoder)
        }
    }
}

extension Optional.Codable: Equatable where Wrapped: Equatable {}
extension Optional.Codable: Hashable where Wrapped: Hashable {}
