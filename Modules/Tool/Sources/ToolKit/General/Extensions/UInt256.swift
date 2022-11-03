// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BigInt
import Foundation

extension BigInt.Sign {
    static func from(string: String) -> BigInt.Sign {
        string.contains(Character("-")) ? .minus : .plus
    }
}

extension BigInt {
    public init?(_ string: String, decimals: Int) {
        let sign = Sign.from(string: string)
        let trimmedString = string.replacingOccurrences(of: "-", with: "")
        guard let maginitude = BigUInt(trimmedString, decimals: decimals) else {
            return nil
        }
        self.init(sign: sign, magnitude: maginitude)
    }
}

extension BigUInt {

    /// - Parameter string: String number. can be: "0.023", "123123123.12312312312"
    /// - Parameter decimals: Number of decimals that string should be multiplyed by
    public init?(_ string: String, decimals: Int) {
        let separators = CharacterSet(charactersIn: ".,")
        let components = string.trimmingCharacters(in: .whitespacesAndNewlines).components(separatedBy: separators)
        guard components.count == 1 || components.count == 2 else { return nil }
        let unitDecimals = decimals
        guard var mainPart = BigUInt(components[0], radix: 10) else { return nil }
        mainPart *= BigUInt(10).power(unitDecimals)
        if components.count == 2 {
            let numDigits = components[1].count
            guard numDigits <= unitDecimals else { return nil }
            guard let afterDecPoint = BigUInt(components[1], radix: 10) else { return nil }
            let extraPart = afterDecPoint * BigUInt(10).power(unitDecimals - numDigits)
            mainPart += extraPart
        }
        self = mainPart
    }

    /// Number to string convertion options
    public struct StringOptions: OptionSet {
        public let rawValue: Int

        public init(rawValue: Int) {
            self.rawValue = rawValue
        }

        /// Fallback to scientific number. (like `1.0e-16`)
        public static let fallbackToScientific = StringOptions(rawValue: 0b1)
        /// Removes last zeroes (will print `1.123` instead of `1.12300000000000`)
        public static let stripZeroes = StringOptions(rawValue: 0b10)
        /// Default options: [.stripZeroes]
        public static let `default`: StringOptions = [.stripZeroes]
    }

    /// Formats a BigUInt object to String. The supplied number is first divided into integer and decimal part based on "toUnits",
    /// then limit the decimal part to "decimals" symbols and uses a "decimalSeparator" as a separator.
    /// Fallbacks to scientific format if higher precision is required.
    /// default: decimals: 18, decimalSeparator: ".", options: .stripZeroes
    public func string(unitDecimals: Int, decimals: Int = 18, decimalSeparator: String = ".", options: StringOptions = .default) -> String {
        guard self != 0 else { return "0" }
        var toDecimals = decimals
        if unitDecimals < toDecimals {
            toDecimals = unitDecimals
        }
        let divisor = BigUInt(10).power(unitDecimals)
        let (quotient, remainder) = quotientAndRemainder(dividingBy: divisor)
        var fullRemainder = String(remainder)
        let fullPaddedRemainder = fullRemainder.leftPadding(toLength: unitDecimals, withPad: "0")
        let remainderPadded = fullPaddedRemainder[0..<toDecimals]
        let offset = remainderPadded.reversed().firstIndex(where: { $0 != "0" })?.base

        if let offset {
            if toDecimals == 0 {
                return String(quotient)
            } else if options.contains(.stripZeroes) {
                return String(quotient) + decimalSeparator + remainderPadded[..<offset]
            } else {
                return String(quotient) + decimalSeparator + remainderPadded
            }
        } else if quotient != 0 || !options.contains(.fallbackToScientific) {
            return String(quotient)
        } else {
            var firstDigit = 0
            for char in fullPaddedRemainder {
                if char == "0" {
                    firstDigit += 1
                } else {
                    let firstDecimalUnit = String(fullPaddedRemainder[firstDigit..<firstDigit + 1])
                    var remainingDigits = ""
                    let numOfRemainingDecimals = fullPaddedRemainder.count - firstDigit - 1
                    if numOfRemainingDecimals <= 0 {
                        remainingDigits = ""
                    } else if numOfRemainingDecimals > decimals {
                        let end = firstDigit + 1 + decimals > fullPaddedRemainder.count ? fullPaddedRemainder.count : firstDigit + 1 + decimals
                        remainingDigits = String(fullPaddedRemainder[firstDigit + 1..<end])
                    } else {
                        remainingDigits = String(fullPaddedRemainder[firstDigit + 1..<fullPaddedRemainder.count])
                    }
                    fullRemainder = firstDecimalUnit
                    if !remainingDigits.isEmpty {
                        fullRemainder += decimalSeparator + remainingDigits
                    }
                    firstDigit += 1
                    break
                }
            }
            return fullRemainder + "e-" + String(firstDigit)
        }
    }
}

extension BigInt {
    /// Typealias
    public typealias StringOptions = BigUInt.StringOptions

    /// Formats a BigInt object to String. The supplied number is first divided into integer and decimal part based on "units",
    /// then limit the decimal part to "decimals" symbols and uses a "decimalSeparator" as a separator.
    /// Fallbacks to scientific format if higher precision is required.
    /// default: decimals: 18, decimalSeparator: ".", options: .stripZeroes
    public func string(unitDecimals: Int, decimals: Int = 18, decimalSeparator: String = ".", options: StringOptions = .default) -> String {
        let formatted = magnitude.string(unitDecimals: unitDecimals, decimals: decimals, decimalSeparator: decimalSeparator, options: options)
        switch sign {
        case .plus:
            return formatted
        case .minus:
            return "-" + formatted
        }
    }
}

extension String {

    fileprivate func leftPadding(toLength: Int, withPad character: Character) -> String {
        let stringLength = count
        if stringLength < toLength {
            return String(repeatElement(character, count: toLength - stringLength)) + self
        } else {
            return String(suffix(toLength))
        }
    }
}
