// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation
import Localization

/// Represents any error that might occur during the pin flow
public enum PinError: Error {

    public enum PinAlert {
        case tooManyAttempts
        case cannotLogin
    }

    /// Signifies that the selected pin is invalid. See `Pin` for more info about it.
    case invalid

    /// Signifies that the selected pin is identical to previous (change flow)
    case identicalToPrevious

    /// Signified that the second pin entered on creation/change flow didn't match the selected one
    case pinMismatch(recovery: () -> Void)

    /// Signifies that the user has entered an incorrect pin code. Has an associated message with the seconds for the PIN lock time, with an optional incorrect pin reminder.
    case incorrectPin(String, Int, PinAlert?)

    /// Signifies that the PIN auth is locked due to exponential backoff. Has an associated message with the remaining lock time.
    case backoff(String, Int, PinAlert?)

    /// Signifies that the user tried to authenticate with the wrong pin too many times
    case tooManyAttempts

    /// Signifies that server is currently under maintenance.
    case serverMaintenance(message: String)

    /// Signifies any unexpected error from our backend
    case serverError(String)

    /// Biometric authentication failure
    case biometricAuthenticationFailed(String)

    /// Signifies that the current operation cannot be completed as there is no internent connection
    case noInternetConnection(recovery: () -> Void)

    /// Stands for any custom error
    case custom(String)

    // Techincal errors
    case unretainedSelf
    case nullifiedPinKey

    // A logout was attempted
    case receivedResponseWhileLoggedOut

    // Error in decryption
    case decryptedPasswordWithZeroLength

    case encryptedPinPasswordFailed(Error)

    /// Converts any type of error into a presentable pin error
    public static func map(from error: Error) -> PinError {
        if let error = error as? PinError {
            return error
        }
        return .custom(LocalizationConstants.Errors.genericError)
    }
}
