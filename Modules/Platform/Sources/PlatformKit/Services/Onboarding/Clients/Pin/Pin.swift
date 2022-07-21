// Copyright © Blockchain Luxembourg S.A. All rights reserved.

/// Model for a user's 4-digit pin
public struct Pin {
    static let invalid = Pin(code: 0000)

    /// Checks if this pin is a valid
    public var isValid: Bool {
        self != Pin.invalid
    }

    /// String representation of the underlying pin
    public var toString: String {
        pinCode.pinToString
    }

    private(set) var pinCode: UInt

    // MARK: - Initializers

    public init(code: UInt) {
        pinCode = code
    }

    public init?(string: String) {
        guard let code = UInt(string) else { return nil }
        self.init(code: code)
    }

    /// Save using injected parameter
    public func save(using settings: AppSettingsAuthenticating) {
        settings.pin = toString
    }
}

// MARK: - Hashable, Equatable

extension Pin: Hashable {
    public static func == (lhs: Pin, rhs: Pin) -> Bool {
        lhs.pinCode == rhs.pinCode
    }

    public func isEqual(_ object: Any?) -> Bool {
        pinCode == (object as? Pin)?.pinCode
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(pinCode)
    }
}

extension UInt {
    var pinToString: String {
        String(format: "%lu", CUnsignedLongLong(self))
    }
}
