// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

@testable import BlockchainApp

class MockWallet: Wallet {

    var mockIsInitialized: Bool = false

    override func isInitialized() -> Bool {
        mockIsInitialized
    }

    var mockNeedsSecondPassword = false

    override func needsSecondPassword() -> Bool {
        mockNeedsSecondPassword
    }

    let guid = String(repeating: "a", count: 36)
    let sharedKey = String(repeating: "b", count: 36)
    private var password: String = "a-password"

    /// When called, invokes the delegate's walletDidDecrypt and walletDidFinishLoad methods
    override func load(withGuid guid: String, sharedKey: String?, password: String?) {
        delegate?.walletDidDecrypt?(withSharedKey: sharedKey, guid: guid)
        delegate?.walletDidFinishLoad?()
    }

    var fetchCalled = false

    override func fetch(with password: String) {
        fetchCalled = true
        self.password = password
    }

    var getHistoryForAllAssetsCalled = false

    override func getHistoryForAllAssets() {
        getHistoryForAllAssetsCalled = true
    }

    override func newAccount(_ password: String!, email: String!) {
        delegate?.didCreateNewAccount?(guid, sharedKey: sharedKey, password: password)
    }

    override func recoverFromMetadata(withMnemonicPassphrase mnemonicPassphrase: String) {
        delegate?.didRecoverWallet?()
    }

    override func recover(withEmail email: String, password recoveryPassword: String, mnemonicPassphrase: String) {
        delegate?.didRecoverWallet?()
    }
}
