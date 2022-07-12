// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

extension DecodingError {
    /// Provides a formatted description of a `DecodingError`, please note the result is not localized intentionally
    public var formattedDescription: String {
        switch self {
        case .dataCorrupted(let context):
            let underlyingError = (context.underlyingError as? NSError)?.debugDescription ?? ""
            return "Data corrupted. \(context.debugDescription) \(underlyingError)"
        case .keyNotFound(let codingKey, let context):
            return "Key not found. Expected -> \(codingKey.stringValue) <- at: \(formattedPath(for: context))"
        case .typeMismatch(_, let context):
            return "Type mismatch. \(context.debugDescription) at: \(formattedPath(for: context))"
        case .valueNotFound(_, let context):
            return "Value not found. -> \(formattedPath(for: context)) <- \(context.debugDescription)"
        @unknown default:
            return "Unknown error while decoding"
        }
    }

    private func formattedPath(for context: DecodingError.Context) -> String {
        context.codingPath.map(\.stringValue).joined(separator: ".")
    }
}

extension EncodingError {
    /// Provides a formatted description of a `EncodingError`, please note the result is not localized intentionally
    public var formattedDescription: String {
        switch self {
        case .invalidValue(_, let context):
            return "Invalid value while encoding found -> \(formattedPath(for: context))"
        @unknown default:
            return "Unknown error while encoding"
        }
    }

    private func formattedPath(for context: EncodingError.Context) -> String {
        context.codingPath.map(\.stringValue).joined(separator: ".")
    }
}
