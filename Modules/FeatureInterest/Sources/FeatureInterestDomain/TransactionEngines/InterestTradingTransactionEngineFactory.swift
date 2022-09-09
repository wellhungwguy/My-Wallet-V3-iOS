// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import FeatureTransactionDomain
import PlatformKit
import ToolKit

/// Transaction Engine Factory for Interest Deposit or Withdraw from/to a Trading Account.
final class InterestTradingTransactionEngineFactory: InterestTradingTransactionEngineFactoryAPI {
    func build(
        action: AssetAction
    ) -> InterestTransactionEngine {
        switch action {
        case .interestTransfer:
            return InterestDepositTradingTransactionEngine()
        case .interestWithdraw:
            return InterestWithdrawTradingTransactionEngine()
        default:
            unimplemented()
        }
    }
}
