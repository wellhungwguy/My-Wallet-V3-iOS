// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit
import FeatureTransactionDomain

final class StellarOnChainTransactionEngineFactory: OnChainTransactionEngineFactory {
    func build() -> OnChainTransactionEngine {
        StellarOnChainTransactionEngine(
            walletCurrencyService: DIKit.resolve(),
            currencyConversionService: DIKit.resolve(),
            feeRepository: DIKit.resolve(),
            transactionDispatcher: DIKit.resolve()
        )
    }
}
