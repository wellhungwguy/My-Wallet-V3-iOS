// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainNamespace
import MoneyKit
import ToolKit

final class PolygonSupport: MoneyKit.PolygonSupport {

    var isEnabled: Bool {
        defer { isEnabledLock.unlock() }
        isEnabledLock.lock()
        return isEnabledLazy
    }

    var isAllTokensEnabled: Bool {
        defer { isAllTokensEnabledLock.unlock() }
        isAllTokensEnabledLock.lock()
        return isAllTokensEnabledLazy
    }

    private lazy var isAllTokensEnabledLazy: Bool = {
        fetchBool(tag: blockchain.app.configuration.polygon.all.tokens.is.enabled)
    }()

    private lazy var isEnabledLazy: Bool = {
        fetchBool(tag: blockchain.app.configuration.polygon.is.enabled)
    }()

    private let isEnabledLock = NSLock()
    private let isAllTokensEnabledLock = NSLock()
    private let app: AppProtocol

    init(app: AppProtocol) {
        self.app = app
    }

    private func fetchBool(tag: Tag.Event) -> Bool {
        guard let value = try? app.remoteConfiguration.get(tag) else {
            return false
        }
        guard let isEnabled = value as? Bool else {
            return false
        }
        return isEnabled
    }

}
