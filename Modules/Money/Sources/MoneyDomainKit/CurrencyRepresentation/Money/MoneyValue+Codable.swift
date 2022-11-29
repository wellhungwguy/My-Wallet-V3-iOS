// Copyright © Blockchain Luxembourg S.A. All rights reserved.

extension MoneyValue: Codable {

    public enum MoneyValueCodingError: Error {
        case invalidMinorValue
    }

    enum CodingKeys: String, CodingKey {
        case value, amount
        case currency
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let valueInMinors = try container.decodeIfPresent(String.self, forKey: .value) ?? container.decode(String.self, forKey: .amount)
        let currency = try container.decode(String.self, forKey: .currency)
        let value = try MoneyValue.create(minor: valueInMinors, currency: CurrencyType(code: currency))
        guard let moneyValue = value else {
            throw MoneyValueCodingError.invalidMinorValue
        }
        self = moneyValue
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(minorString, forKey: .value)
        try container.encode(minorString, forKey: .amount)
        try container.encode(code, forKey: .currency)
    }
}
