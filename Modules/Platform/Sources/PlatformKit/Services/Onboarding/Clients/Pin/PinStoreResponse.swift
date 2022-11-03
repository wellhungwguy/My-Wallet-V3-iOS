// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Errors
import Localization

public struct PinStoreResponse: Decodable & Error {

    public enum StatusCode: Int, Decodable {
        case success = 0 // Pin retry succeeded
        case deleted = 1 // Pin retry failed and data was deleted from store
        case incorrect = 2 // Incorrect pin
        case unknown = 3 // Unknown Error
        case duplicateKey = 4 // Duplicate Key
        case backoff = 5 // PIN is locked due to exponential backoff
    }

    private enum CodingKeys: String, CodingKey {
        case code
        case error
        case remaining
        case pinDecryptionValue = "success"
        case key
        case value
    }

    /// This is a status code from the server
    public let statusCode: StatusCode?

    /// This is an error string from the server or nil
    public let error: String?

    /// This is the remaining PIN locked time in milliseconds due to exponential back off
    public let remaining: Int?

    /// The PIN decryption value from the server
    public let pinDecryptionValue: String?

    /// Pin code lookup key
    let key: String?

    /// Encryption string
    let value: String?
}

extension PinStoreResponse {

    /// Is the response successful
    public var isSuccessful: Bool {
        statusCode == .success && error == nil
    }

    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        statusCode = try values.decode(StatusCode.self, forKey: .code)
        pinDecryptionValue = try values.decodeIfPresent(String.self, forKey: .pinDecryptionValue)
        key = try values.decodeIfPresent(String.self, forKey: .key)
        value = try values.decodeIfPresent(String.self, forKey: .value)
        error = try values.decodeIfPresent(String.self, forKey: .error)
        remaining = try values.decodeIfPresent(Int.self, forKey: .remaining)
    }

    public func toPinError() -> PinError {
        // First verify that the status code was received
        guard let code = statusCode else {
            return PinError.serverError(LocalizationConstants.Errors.genericError)
        }

        switch code {
        case .deleted:
            return PinError.tooManyAttempts
        case .incorrect:
            guard let remaining else {
                fatalError("Incorrect PIN should have an remaining field")
            }
            let message = LocalizationConstants.Pin.incorrect
            return PinError.incorrectPin(message, remaining, nil)
        case .backoff:
            guard let remaining else {
                fatalError("Backoff should have an remaining field")
            }
            let message = LocalizationConstants.Pin.backoff
            return PinError.backoff(message, remaining, nil)
        case .duplicateKey, .unknown:
            return PinError.serverError(LocalizationConstants.Errors.genericError)
        case .success:
            fatalError("Should not happen because toPinError expects an error response")
        }
    }
}

extension PinStoreResponse: FromNetworkErrorConvertible {

    public static func from(
        _ communicatorError: NetworkError
    ) -> PinStoreResponse {
        PinStoreResponse(
            statusCode: nil,
            error: String(describing: communicatorError),
            remaining: nil,
            pinDecryptionValue: nil,
            key: nil,
            value: nil
        )
    }
}
