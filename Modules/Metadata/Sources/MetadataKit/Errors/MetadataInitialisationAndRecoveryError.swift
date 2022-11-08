// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

public enum MetadataInitialisationAndRecoveryError: LocalizedError, Equatable {
    case failedToDeriveSecondPasswordNode(DeriveSecondPasswordNodeError)
    case failedToDeriveRemoteMetadataNode(MetadataDerivationError)
    case failedToDeriveMasterKey(MasterKeyError)
    case invalidMnemonic(MnemonicError)
    case failedToFetchCredentials(MetadataFetchError)

    public var errorDescription: String? {
        switch self {
        case .failedToDeriveSecondPasswordNode(let deriveSecondPasswordNodeError):
            return deriveSecondPasswordNodeError.errorDescription
        case .failedToDeriveRemoteMetadataNode(let metadataDerivationError):
            return metadataDerivationError.errorDescription
        case .failedToDeriveMasterKey(let masterKeyError):
            return masterKeyError.errorDescription
        case .invalidMnemonic(let mnemonicError):
            return mnemonicError.errorDescription
        case .failedToFetchCredentials(let metadataFetchError):
            return metadataFetchError.errorDescription
        }
    }
}
