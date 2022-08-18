// Copyright © Blockchain Luxembourg S.A. All rights reserved.
// swiftlint:disable let_var_whitespace

public typealias CodingIndex = Either<Int, String>

extension CodingIndex: CodingKey {

    @inlinable public var stringValue: String { description }
    @inlinable public init?(stringValue: String) { self.init(stringValue) }

    @inlinable public var intValue: Int? { left }
    @inlinable public init?(intValue: Int) { self.init(intValue) }
}

extension CodingIndex: ExpressibleByIntegerLiteral {
    @inlinable public init(integerLiteral value: Int) { self.init(value) }
}

extension CodingIndex: ExpressibleByStringLiteral {
    @inlinable public init(stringLiteral value: String) { self.init(value) }
}

extension CodingIndex: ExpressibleByUnicodeScalarLiteral {
    @inlinable public init(unicodeScalarLiteral value: String) { self.init(value) }
}

extension CodingIndex: ExpressibleByExtendedGraphemeClusterLiteral {
    @inlinable public init(extendedGraphemeClusterLiteral value: String) { self.init(value) }
}

extension Collection where Element == CodingIndex {

    @inlinable public func joined(separator: String = ".") -> String {
        lazy.map(\.stringValue).joined(separator: separator)
    }
}
