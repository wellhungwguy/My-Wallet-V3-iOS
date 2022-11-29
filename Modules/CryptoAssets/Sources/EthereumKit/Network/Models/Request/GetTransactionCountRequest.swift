// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

struct GetTransactionCountRequest: Encodable {
    let id: Int = 0
    let jsonrpc: String = "2.0"
    let method: String = "eth_getTransactionCount"
    let params: [String]

    init(address: String) {
        self.params = [address, "latest"]
    }
}
