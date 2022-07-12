// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

public enum MetadataInitialisationAndRecoveryError: Error, Equatable {
    case failedToDeriveSecondPasswordNode(DeriveSecondPasswordNodeError)
    case failedToDeriveRemoteMetadataNode(MetadataDerivationError)
    case failedToDeriveMasterKey(MasterKeyError)
    case invalidMnemonic(MnemonicError)
    case failedToFetchCredentials(MetadataFetchError)
}
