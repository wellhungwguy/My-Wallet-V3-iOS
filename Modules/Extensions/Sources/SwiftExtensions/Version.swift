// Copyright © Blockchain Luxembourg S.A. All rights reserved.

public struct Version {

    public let major: Int
    public let minor: Int
    public let patch: Int

    public init(
        _ major: Int,
        _ minor: Int,
        _ patch: Int
    ) {
        precondition(major >= 0 && minor >= 0 && patch >= 0, "Negative versioning is invalid")
        self.major = major
        self.minor = minor
        self.patch = patch
    }

    public var string: String {
        "\(major).\(minor).\(patch)"
    }
}

extension Version {

    public enum Error: Swift.Error {
        case nonASCII
        case invalidNumberOfVersionIdentifiers
        case nonNumericalOrEmpty([String])
    }
}

extension Version: ExpressibleByStringLiteral, LosslessStringConvertible {

    public var description: String {
        "\(major).\(minor).\(patch)"
    }

    public init(stringLiteral value: StaticString) {
        // swiftlint:disable:next force_try
        try! self.init(
            string: value.hasPointerRepresentation
                ? value.withUTF8Buffer { String(decoding: $0, as: UTF8.self) }
                : .init(value.unicodeScalar)
        )
    }

    public init(extendedGraphemeClusterLiteral value: StaticString) {
        self.init(stringLiteral: value)
    }

    public init(unicodeScalarLiteral value: StaticString) {
        self.init(stringLiteral: value)
    }

    public init?(_ description: String) {
        try? self.init(string: description)
    }

    public init(string: String, usesLenientParsing: Bool = false) throws {
        guard string.allSatisfy(\.isASCII) else {
            throw Error.nonASCII
        }
        let identifiers = string.split(separator: ".", omittingEmptySubsequences: false)
        guard identifiers.count == 3 || (usesLenientParsing && identifiers.count == 2) else {
            throw Error.invalidNumberOfVersionIdentifiers
        }
        guard
            let major = Int(identifiers[0]),
            let minor = Int(identifiers[1]),
            let patch = usesLenientParsing && identifiers.count == 2 ? 0 : Int(identifiers[2])
        else {
            throw Error.nonNumericalOrEmpty(identifiers.map(\.string))
        }
        self.major = major
        self.minor = minor
        self.patch = patch
    }
}

extension Version: Comparable, Hashable {

    @inlinable
    public static func == (lhs: Version, rhs: Version) -> Bool {
        !(lhs < rhs) && !(lhs > rhs)
    }

    public static func < (lhs: Version, rhs: Version) -> Bool {
        [lhs.major, lhs.minor, lhs.patch].lexicographicallyPrecedes([rhs.major, rhs.minor, rhs.patch])
    }

    // [SR-11588](https://bugs.swift.org/browse/SR-11588)
    public func hash(into hasher: inout Hasher) {
        hasher.combine(major)
        hasher.combine(minor)
        hasher.combine(patch)
    }
}

extension Version: Codable {

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(description)
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let string = try container.decode(String.self)
        guard let version = Version(string) else {
            throw DecodingError.dataCorrupted(
                .init(
                    codingPath: decoder.codingPath,
                    debugDescription: "Invalid version string \(string)"
                )
            )
        }
        self = version
    }
}

extension Range where Bound == Version {

    public func contains(version: Version) -> Bool {
        if lowerBound == version { return true }
        return version >= lowerBound && version < upperBound
    }
}
