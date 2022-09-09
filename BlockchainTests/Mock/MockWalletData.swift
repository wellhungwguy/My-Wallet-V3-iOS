// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

@testable import BlockchainApp

class MockWalletData: WalletProtocol {

    @objc var password: String? = "password"
    @objc var isNew = true

    weak var delegate: WalletDelegate?
    private let initialized: Bool

    var isBitcoinWalletFunded: Bool { false }

    init(initialized: Bool, delegate: WalletDelegate?) {
        self.initialized = initialized
        self.delegate = delegate
    }

    @objc func isInitialized() -> Bool {
        initialized
    }

    @objc func encrypt(_ data: String, password: String) -> String {
        password
    }

    /// When called, invokes the delegate's walletDidDecrypt and walletDidFinishLoad methods
    @objc func load(withGuid guid: String!, sharedKey: String!, password: String!) {
        delegate?.walletDidDecrypt!(withSharedKey: sharedKey, guid: guid)
        delegate?.walletDidFinishLoad!()
    }
}
