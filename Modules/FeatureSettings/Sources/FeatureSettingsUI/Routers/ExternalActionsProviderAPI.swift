// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

public protocol ExternalActionsProviderAPI {
    func logout()
    func logoutAndForgetWallet()
    func handleSupport()
    func handleSecureChannel()
}
