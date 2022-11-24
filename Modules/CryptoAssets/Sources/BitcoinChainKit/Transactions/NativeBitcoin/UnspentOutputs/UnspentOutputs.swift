// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BigInt
import PlatformKit

public struct UnspentOutputs: Equatable {

    let outputs: [UnspentOutput]
}

extension UnspentOutputs {
    init(networkResponse: UnspentOutputsResponse, coin: BitcoinChainCoin) {
        self.outputs = networkResponse
            .unspent_outputs
            .map { UnspentOutput(response: $0, coin: coin) }
    }
}
