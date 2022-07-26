// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import FeatureTransactionDomain

public final class BitcoinOnChainTransactionEngineFactory<Token: BitcoinChainToken>: OnChainTransactionEngineFactory {
    public init() {}
    public func build() -> OnChainTransactionEngine {
        BitcoinOnChainTransactionEngine<Token>()
    }
}
