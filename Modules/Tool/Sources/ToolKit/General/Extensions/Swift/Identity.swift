// Copyright © Blockchain Luxembourg S.A. All rights reserved.

// swiftlint:disable type_name
public struct Identity<T>: Codable, Hashable {

    public let value: String

    public init(_ value: String) {
        self.value = value
    }

    public init(from decoder: Decoder) throws {
        value = try String(from: decoder)
    }

    public func encode(to encoder: Encoder) throws {
        try value.encode(to: encoder)
    }
}

extension Identity: ExpressibleByStringLiteral {

    public init(stringLiteral value: StaticString) {
        self.value = value.description
    }
}
