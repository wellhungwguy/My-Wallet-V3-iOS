// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import ComposableArchitecture
import Errors
import PlatformKit

struct IdentityVerificationState: Equatable {
    @BindableState var documentTypes: [KYCDocumentType] = []
    var isLoading = false
}
