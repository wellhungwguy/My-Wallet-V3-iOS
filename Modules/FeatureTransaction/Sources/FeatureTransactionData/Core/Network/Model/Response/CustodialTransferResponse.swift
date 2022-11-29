// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import MoneyKit
import PlatformKit

/// The response object returned after submitting a custodial transfer to a non custodial address.
/// At the time of writing, `Status`/`State` is not exposed to clients.
struct CustodialTransferResponse: Decodable {

    enum Status: String {
        case none
        case pending
        case refunded
        case complete
        case rejected
    }

    let identifier: String
    let userId: String
    let cryptoValue: CryptoValue

    /// NOTE: `State`/`Status` is not mapped yet as it is not exposed
    /// by the API. However, it may well be in the future so as
    /// we can show the status of the withdrawal after submission.
    enum CodingKeys: String, CodingKey {
        case id
        case user
        case amount
        case symbol
        case value
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        self.identifier = try values.decode(String.self, forKey: .id)
        self.userId = try values.decode(String.self, forKey: .user)
        let amountContainer = try values.nestedContainer(keyedBy: CodingKeys.self, forKey: .amount)
        let symbol = try amountContainer.decode(String.self, forKey: .symbol)
        guard let currency = CryptoCurrency(code: symbol) else {
            throw DecodingError.dataCorruptedError(
                forKey: .symbol,
                in: values,
                debugDescription: "CryptoCurrency not recognised."
            )
        }
        let value = try amountContainer.decode(String.self, forKey: .value)
        self.cryptoValue = CryptoValue.create(major: value, currency: currency) ?? .zero(currency: currency)
    }
}
