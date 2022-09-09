// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import FeatureTransactionDomain
import Foundation
import PlatformKit

struct WalletConnectEngineFactory: WalletConnectEngineFactoryAPI {
    func build(
        target: TransactionTarget
    ) -> TransactionEngine {
        switch target {
        case is EthereumSignMessageTarget:
            return WalletConnectSignMessageEngine()
        case let target as EthereumSendTransactionTarget:
            return WalletConnectTransactionEngine(
                network: target.network
            )
        default:
            fatalError("Transaction target '\(type(of: target))' not supported.")
        }
    }
}
