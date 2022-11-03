// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainNamespace
import MoneyDomainKit
import ToolKit

protocol EVMSupportAPI: AnyObject {

    var sanitizeTokenNamesEnabled: Bool { get }

    func isEnabled(network: AssetModelType.ERC20ParentChain) -> Bool
}

final class EVMSupport: EVMSupportAPI {

    func isEnabled(network: AssetModelType.ERC20ParentChain) -> Bool {
        switch network {
        case .ethereum:
            return true
        case .polygon:
            return fetchBool(tag: blockchain.app.configuration.evm.polygon.is.enabled)
        case .bnb:
            return fetchBool(tag: blockchain.app.configuration.evm.bnb.is.enabled)
        case .avax:
            return fetchBool(tag: blockchain.app.configuration.evm.avax.is.enabled)
        }
    }

    var sanitizeTokenNamesEnabled: Bool {
        defer { sanitizeTokenNamesEnabledLock.unlock() }
        sanitizeTokenNamesEnabledLock.lock()
        return sanitizeTokenNamesEnabledLazy
    }

    private lazy var sanitizeTokenNamesEnabledLazy: Bool = fetchBool(
        tag: blockchain.app.configuration.evm.name.sanitize.is.enabled
    )

    private let sanitizeTokenNamesEnabledLock = NSLock()
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
