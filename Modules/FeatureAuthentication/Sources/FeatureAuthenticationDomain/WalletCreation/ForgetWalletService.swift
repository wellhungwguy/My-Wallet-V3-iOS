// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import ToolKit
import WalletPayloadKit

public struct ForgetWalletService {
    /// Clears the in-memory wallet state and removes values from `WalletRepo`
    public var forget: () -> AnyPublisher<Void, ForgetWalletError>
}

extension ForgetWalletService {
    public static func live(
        forgetWallet: ForgetWalletAPI
    ) -> ForgetWalletService {
        ForgetWalletService(
            forget: { () -> AnyPublisher<Void, ForgetWalletError> in
                forgetWallet.forget()
            }
        )
    }
}
