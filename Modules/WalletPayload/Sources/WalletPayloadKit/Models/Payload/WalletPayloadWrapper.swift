// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

enum WalletVersion: Int {
    case v4 = 4
    case v3 = 3
    case v2 = 2
    case v1 = 1

    static let supportedVersion = WalletVersion.v4
}

/// The wallet payload as it is returned by the server
public struct WalletPayloadWrapper: Equatable {

    /// Possible errors for payload
    public enum MappingError: Error {

        /// Missing raw string
        case missingRawInput

        /// Cannot convert the raw input to `Data`
        case dataConversionFailure
    }

    public let pbkdf2IterationCount: UInt32
    public let version: Int
    public let payload: String
}

// MARK: - Codable

extension WalletPayloadWrapper: Codable {

    enum CodingKeys: String, CodingKey {
        case pbkdf2IterationCount = "pbkdf2_iterations"
        case version
        case payload
    }

    public init(string: String?) throws {
        guard let string = string else { throw MappingError.missingRawInput }
        guard let data = string.data(using: .utf8) else { throw MappingError.dataConversionFailure }
        self = try data.decode(to: WalletPayloadWrapper.self)
    }
}
