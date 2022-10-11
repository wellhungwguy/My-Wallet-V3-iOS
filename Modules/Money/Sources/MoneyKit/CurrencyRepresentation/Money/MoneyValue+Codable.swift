// Copyright © Blockchain Luxembourg S.A. All rights reserved.

extension MoneyValue: Decodable {

    public enum MoneyValueCodingError: Error {
        case invalidMinorValue
    }

    enum CodingKeys: String, CodingKey {
        case value
        case currency
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let valueInMinors = try container.decode(String.self, forKey: .value)
        let currency = try container.decode(String.self, forKey: .currency)
        let value = try MoneyValue.create(minor: valueInMinors, currency: CurrencyType(code: currency))
        guard let moneyValue = value else {
            throw MoneyValueCodingError.invalidMinorValue
        }
        self = moneyValue
    }
}
