// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Errors

public enum KYCFlowError: Error, Equatable {
    case invalidForm
    case networkError(NabuNetworkError)
}
