// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import FeatureTransactionDomain

struct AvailableTradingPairsResponse: Decodable {

    let pairs: [String]

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        self.pairs = try container.decode([String].self)
    }
}
