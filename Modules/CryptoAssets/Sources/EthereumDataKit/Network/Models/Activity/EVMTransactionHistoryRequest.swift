// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import EthereumKit

struct EVMTransactionHistoryRequest: Encodable {
    let addresses: [String]
    let network: String
    let apiCode: String
    let identifier: String?
}
