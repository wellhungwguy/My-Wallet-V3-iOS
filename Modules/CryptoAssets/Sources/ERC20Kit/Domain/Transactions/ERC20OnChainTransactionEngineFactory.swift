// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import FeatureTransactionDomain
import MoneyKit
import PlatformKit

final class ERC20OnChainTransactionEngineFactory: OnChainTransactionEngineFactory {

    private let erc20Token: AssetModel

    init(erc20Token: AssetModel) {
        self.erc20Token = erc20Token
    }

    func build() -> OnChainTransactionEngine {
        ERC20OnChainTransactionEngine(
            erc20Token: erc20Token
        )
    }
}
