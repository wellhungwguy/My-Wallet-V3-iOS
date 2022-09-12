// Copyright © Blockchain Luxembourg S.A. All rights reserved.

/**
 Represents an authentication error.

 Set **description** to `nil` to indicate that the error should be handled silently.
 */
public struct AuthenticationError: Error, Equatable {
    public enum ErrorCode: Int {
        case noInternet = 300
        case errorDecryptingWallet
        case invalidSharedKey
    }

    public let code: ErrorCode
    public let description: String?

    /**
     - Parameters:
        - code: The code associated with the error object.
        - description: The description associated with the error object.
     */
    public init(code: ErrorCode, description: String? = nil) {
        self.code = code
        self.description = description
    }
}
