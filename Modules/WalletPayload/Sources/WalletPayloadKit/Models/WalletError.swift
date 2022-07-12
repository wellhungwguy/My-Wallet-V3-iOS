// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Localization
import MetadataKit
import ToolKit

public enum WalletError: LocalizedError, Equatable {
    case unknown
    case payloadNotFound
    case initialization(WalletInitializationError)
    case decryption(WalletDecryptionError)
    case encryption(WalletEncodingError)
    case recovery(WalletRecoverError)
    case upgrade(WalletUpgradeError)
    case sync(WalletSyncError)

    public var errorDescription: String? {
        switch self {
        case .payloadNotFound:
            return LocalizationConstants.WalletPayloadKit.Error.payloadNotFound
        case .decryption(let error):
            return error.errorDescription
        case .initialization(let error):
            return error.errorDescription
        case .recovery(let error):
            return error.errorDescription
        case .encryption(let error):
            return error.errorDescription
        case .upgrade(let error):
            return error.errorDescription
        case .sync(let error):
            return error.errorDescription
        case .unknown:
            return LocalizationConstants.WalletPayloadKit.Error.unknown
        }
    }

    static func map(from error: PayloadCryptoError) -> WalletError {
        switch error {
        case .decodingFailed:
            return .decryption(.genericDecodeError)
        case .noPassword:
            return .initialization(.invalidSecondPassword)
        case .keyDerivationFailed:
            return .initialization(.invalidSecondPassword)
        case .encryptionFailed:
            return .initialization(.invalidSecondPassword)
        case .decryptionFailed:
            return .initialization(.invalidSecondPassword)
        case .unknown:
            return .unknown
        case .noEncryptedWalletData:
            return .unknown
        case .unsupportedPayloadVersion:
            return .unknown
        case .failedToDecryptV1Payload:
            return .unknown
        }
    }
}

public enum WalletInitializationError: LocalizedError, Equatable {
    case unknown
    case missingWallet
    case missingSeedHex
    case metadataInitialization(MetadataInitialisationError)
    case metadataInitializationRecovery(MetadataInitialisationAndRecoveryError)
    case needsSecondPassword
    case invalidSecondPassword

    public var errorDescription: String? {
        switch self {
        case .unknown:
            return LocalizationConstants.WalletPayloadKit.WalletInitializationConstants.unknown
        case .missingWallet:
            return LocalizationConstants.WalletPayloadKit.WalletInitializationConstants.missingWallet
        case .missingSeedHex:
            return LocalizationConstants.WalletPayloadKit.WalletInitializationConstants.missingSeedHex
        case .metadataInitialization(let underlyingError):
            return String(
                format: LocalizationConstants.WalletPayloadKit.WalletInitializationConstants.metadataInitialization,
                underlyingError.localizedDescription
            )
        case .metadataInitializationRecovery(let underlyingError):
            return String(
                format: LocalizationConstants.WalletPayloadKit.WalletInitializationConstants.metadataInitialization,
                underlyingError.localizedDescription
            )
        case .needsSecondPassword:
            return LocalizationConstants.WalletPayloadKit.WalletInitializationConstants.needsSecondPassword
        case .invalidSecondPassword:
            return LocalizationConstants.WalletPayloadKit.WalletInitializationConstants.invalidSecondPassword
        }
    }
}

public enum WalletRecoverError: LocalizedError, Equatable {
    case unknown
    case invalidMnemonic
    case unableToRecoverFromMetadata
    case failedToRecoverWallet

    public var errorDescription: String? {
        switch self {
        case .unknown:
            return LocalizationConstants.WalletPayloadKit.WalletRecoverErrorConstants.unknown
        case .invalidMnemonic:
            return LocalizationConstants.WalletPayloadKit.WalletRecoverErrorConstants.invalidMnemonic
        case .failedToRecoverWallet:
            return LocalizationConstants.WalletPayloadKit.WalletRecoverErrorConstants.failedToRecoverWallet
        case .unableToRecoverFromMetadata:
            // Intentionally nil
            // This error indicates that the wallet from a mnemonic was not previously created by Blockchain.com
            // but another wallet provider, so in this case we will import a wallet and create a new account.
            return nil
        }
    }
}

public enum WalletDecryptionError: LocalizedError, Equatable {
    case decryptionError
    case decodeError(DecodingError)
    case genericDecodeError
    case hdWalletCreation

    public var errorDescription: String? {
        switch self {
        case .decryptionError:
            return LocalizationConstants.WalletPayloadKit.Error.decryptionFailed
        case .decodeError(let error):
            return error.formattedDescription
        case .genericDecodeError:
            return LocalizationConstants.WalletPayloadKit.Error.unknown
        case .hdWalletCreation:
            unimplemented("WalletCore failure when creating HDWallet from seedHex")
        }
    }

    public static func == (lhs: WalletDecryptionError, rhs: WalletDecryptionError) -> Bool {
        switch (lhs, rhs) {
        case (.decryptionError, decryptionError):
            return true
        case (.decodeError(let lhsError), .decodeError(let rhsError)):
            return lhsError.localizedDescription == rhsError.localizedDescription
        case (.genericDecodeError, .genericDecodeError):
            return true
        default:
            return false
        }
    }
}

public enum WalletEncodingError: LocalizedError, Equatable {
    case encryptionFailure
    case encodingError(EncodingError)
    case genericFailure
    case expectedEncryptedPayload

    public var errorDescription: String? {
        switch self {
        case .encryptionFailure:
            return LocalizationConstants.WalletPayloadKit.WalletEncodingErrorConstants.encryptionFailure
        case .encodingError(let encodingError):
            return String(
                format: LocalizationConstants.WalletPayloadKit.WalletEncodingErrorConstants.encodingError,
                encodingError.formattedDescription
            )
        case .genericFailure:
            return LocalizationConstants.WalletPayloadKit.WalletEncodingErrorConstants.genericFailure
        case .expectedEncryptedPayload:
            return LocalizationConstants.WalletPayloadKit.WalletEncodingErrorConstants.expectedEncryptedPayload
        }
    }

    public static func == (lhs: WalletEncodingError, rhs: WalletEncodingError) -> Bool {
        switch (lhs, rhs) {
        case (.encryptionFailure, encryptionFailure):
            return true
        case (.genericFailure, genericFailure):
            return true
        case (.expectedEncryptedPayload, expectedEncryptedPayload):
            return true
        case (.encodingError(let lhsError), .encodingError(let rhsError)):
            return lhsError.errorDescription == rhsError.errorDescription
        default:
            return false
        }
    }
}
