// Copyright © Blockchain Luxembourg S.A. All rights reserved.

@testable import FeatureAuthenticationDomain

import Combine
import ToolKit
import WalletPayloadKit

extension ForgetWalletService {
    public static func mock(called: @escaping () -> Void) -> Self {
        ForgetWalletService(
            forget: { () -> AnyPublisher<EmptyValue, ForgetWalletError> in
                called()
                return .just(.noValue)
            }
        )
    }
}
