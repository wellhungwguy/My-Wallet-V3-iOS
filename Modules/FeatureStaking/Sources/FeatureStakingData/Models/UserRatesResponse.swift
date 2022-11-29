// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

struct StakingRateResponse: Decodable {
    let rate: Double
    let commision: Double
}

struct StakingUserRatesResponse: Decodable {
    let rates: [String: StakingRateResponse]
}
