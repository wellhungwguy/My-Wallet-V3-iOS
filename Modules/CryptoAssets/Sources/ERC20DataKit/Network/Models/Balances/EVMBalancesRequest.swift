// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import EthereumKit

struct EVMBalancesRequest: Encodable {
    let addresses: [String]
    let network: String
    let apiCode: String
}
