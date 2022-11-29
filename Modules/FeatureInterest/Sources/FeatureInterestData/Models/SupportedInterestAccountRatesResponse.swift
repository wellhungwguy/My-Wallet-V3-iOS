// Copyright © Blockchain Luxembourg S.A. All rights reserved.

struct SupportedInterestAccountRatesResponse: Decodable {

    static let empty = SupportedInterestAccountRatesResponse()

    // MARK: - Properties

    let rates: [InterestAccountRateResponse]

    private enum CodingKeys: CodingKey {
        case rates
    }

    // MARK: - Init

    private init() {
        self.rates = []
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let values = try container.decode([String: Double].self, forKey: .rates)
        self.rates = values.map { (key: String, value: Double) in
            InterestAccountRateResponse(currency: key, rate: value)
        }
    }
}
