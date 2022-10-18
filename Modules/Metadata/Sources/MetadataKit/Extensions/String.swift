// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

extension String {

    /// Creates a string from the given Unicode code units using the `UTF8` encoding.
    /// - Parameter codeUnits: A collection of code units encoded in the encoding
    ///     specified in `sourceEncoding`.
    /// - Returns: The decoded string
    @inlinable static func decodeFromUTF8(
        codeUnits: some Collection<UTF8.CodeUnit>
    ) -> Self {
        Self(decoding: codeUnits, as: UTF8.self)
    }
}

extension String {

    /// Decodes a JSON string
    /// - Parameter type: the `Decodable` type to decode into
    /// - Returns: A `Result` of the type or a decoding error
    func decodeJSON<T: Decodable>(to type: T.Type) -> Result<T, DecodingError> {
        JSONDecoder().decode(type: T.self, from: Data(utf8))
    }
}
