// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

extension JSONEncoder {

    /// Encodes the given top-level value and returns its JSON representation.
    ///
    /// - parameter value: The value to encode.
    /// - returns: A new `Data` value containing the encoded JSON data.
    /// - throws: `EncodingError.invalidValue` if a non-conforming floating-point value is encountered during encoding, and the encoding strategy is `.throw`.
    /// - throws: An error if any value throws an error during encoding.
    func encode(value: some Encodable) -> Result<Data, EncodingError> {
        Result { try encode(value) }
            .mapError { error -> EncodingError in
                error as! EncodingError // This is safe because `encode` always throws an `EncodingError`
            }
    }
}
