// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import PlatformKit

public protocol InterestTradingTransactionEngineFactoryAPI {
    func build(
        action: AssetAction
    ) -> InterestTransactionEngine
}
