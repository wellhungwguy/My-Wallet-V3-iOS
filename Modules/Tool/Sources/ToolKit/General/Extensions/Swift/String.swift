// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

extension StringProtocol {

    public func dropPrefix<S>(_ contents: S) -> SubSequence where S: StringProtocol {
        hasPrefix(contents) ? self[index(startIndex, offsetBy: contents.count)...] : self[...]
    }

    public func dropSuffix<S>(_ contents: S) -> SubSequence where S: StringProtocol {
        hasSuffix(contents) ? self[..<index(endIndex, offsetBy: -contents.count)] : self[...]
    }
}

extension StringProtocol {
    public var string: String { String(self) }
}

extension StringProtocol {

    public func interpolating(_ args: CVarArg...) -> String {
        String(format: string, arguments: args)
    }
}

// swiftlint:disable let_var_whitespace
public protocol NewTypeString: Codable, Hashable, Comparable, ExpressibleByStringLiteral, LosslessStringConvertible {
    var value: String { get }
    init(_ value: String)
}

extension NewTypeString {
    public init(stringLiteral value: String) { self.init(value) }
}

extension NewTypeString {
    public init(from decoder: Decoder) throws { try self.init(String(from: decoder)) }
    public func encode(to encoder: Encoder) throws { try value.encode(to: encoder) }
}

extension NewTypeString {
    public var description: String { value }
    public init?(_ description: String) { self.init(description) }
}

extension NewTypeString {
    public static func < (lhs: Self, rhs: Self) -> Bool { lhs.value < rhs.value }
}

extension String {

    @inlinable public func snakeCase() -> String {
        guard !isEmpty else { return self }

        var words: [Range<String.Index>] = []
        var start = startIndex
        var search = index(after: start)..<endIndex

        while let upperCaseRange = rangeOfCharacter(from: CharacterSet.uppercaseLetters, range: search) {
            let untilUpperCase = start..<upperCaseRange.lowerBound
            words.append(untilUpperCase)

            search = upperCaseRange.lowerBound..<search.upperBound
            guard let lowerCaseRange = rangeOfCharacter(from: CharacterSet.lowercaseLetters, range: search) else {
                start = search.lowerBound
                break
            }

            let nextCharacterAfterCapital = index(after: upperCaseRange.lowerBound)
            if lowerCaseRange.lowerBound == nextCharacterAfterCapital {
                start = upperCaseRange.lowerBound
            } else {
                let beforeLowerIndex = index(before: lowerCaseRange.lowerBound)
                words.append(upperCaseRange.lowerBound..<beforeLowerIndex)
                start = beforeLowerIndex
            }
            search = lowerCaseRange.upperBound..<search.upperBound
        }
        words.append(start..<search.upperBound)
        return words
            .map { self[$0].lowercased() }
            .joined(separator: "_")
    }
}

extension StaticString {

    var string: String {
        hasPointerRepresentation
            ? withUTF8Buffer { String(decoding: $0, as: UTF8.self) }
            : .init(unicodeScalar)
    }
}

extension NSRegularExpression {

    public convenience init(_ pattern: StaticString) {
        do {
            try self.init(pattern: pattern.string)
        } catch {
            preconditionFailure("Illegal regular expression: \(pattern).")
        }
    }
}

extension NSRegularExpression {

    public func matches(_ string: String) -> Bool {
        let range = NSRange(location: 0, length: string.utf16.count)
        return firstMatch(in: string, options: [], range: range) != nil
    }
}

extension String {

    public static func ~= (lhs: String, rhs: String) -> Bool {
        guard let regex = try? NSRegularExpression(pattern: rhs) else { return false }
        return regex.matches(lhs)
    }

    public static func ~= (lhs: String, rhs: StaticString) -> Bool {
        NSRegularExpression(rhs).matches(lhs)
    }
}
