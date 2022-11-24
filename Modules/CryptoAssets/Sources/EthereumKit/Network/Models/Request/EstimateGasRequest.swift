// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

struct EstimateGasRequest: Encodable {
    let id: Int = 0
    let jsonrpc: String = "2.0"
    let method: String = "eth_estimateGas"
    let params: [EthereumJsonRpcTransaction]

    init(transaction: EthereumJsonRpcTransaction) {
        self.params = [transaction]
    }
}
