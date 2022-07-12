// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Errors
import Foundation
import Localization
import ToolKit

public enum WalletSyncError: LocalizedError, Equatable {
    case unknown
    case encodingError(WalletEncodingError)
    case verificationFailure(EncryptAndVerifyError)
    case networkFailure(NetworkError)
    case syncPubKeysFailure(SyncPubKeysAddressesProviderError)

    public var errorDescription: String? {
        switch self {
        case .unknown:
            return LocalizationConstants.WalletPayloadKit.Error.unknown
        case .encodingError(let walletEncodingError):
            return walletEncodingError.errorDescription
        case .verificationFailure(let encryptAndVerifyError):
            return encryptAndVerifyError.errorDescription
        case .networkFailure(let networkError):
            return networkError.description
        case .syncPubKeysFailure(let error):
            return error.localizedDescription
        }
    }
}
