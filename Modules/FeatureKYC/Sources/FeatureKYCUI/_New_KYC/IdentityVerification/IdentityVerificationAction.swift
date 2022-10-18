// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import ComposableArchitecture
import Errors
import PlatformKit

enum IdentityVerificationAction: Equatable {
    case startVerification
    case fetchSupportedDocumentTypes
    case didReceiveSupportedDocumentTypesResult(Result<[KYCDocumentType], NabuNetworkError>)
    case onViewAppear
}
