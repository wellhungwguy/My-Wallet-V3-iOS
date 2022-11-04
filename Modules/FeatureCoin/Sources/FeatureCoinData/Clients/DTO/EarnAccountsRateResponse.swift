// Copyright © Blockchain Luxembourg S.A. All rights reserved.

public struct InterestAccountRateResponse: Decodable {
    let currency: String
    let rate: Double
}

public struct StakingAccountRateResponse: Decodable {
    let rate: Double
    let commission: Double
}

public struct StakingUserRatesResponse: Decodable {
    let rates: [String: StakingAccountRateResponse]

    subscript(currencyCode: String) -> StakingAccountRateResponse? {
        rates[currencyCode]
    }
}
