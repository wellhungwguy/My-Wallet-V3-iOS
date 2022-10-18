// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BigInt
import MoneyKit
import PlatformKit

struct StellarTransactionFee: TransactionFee, Decodable {

    enum CodingKeys: String, CodingKey {
        case regular
        case priority
    }

    static let cryptoType: HasPathComponent = CryptoCurrency.stellar
    static let `default` = StellarTransactionFee(
        regular: 100,
        priority: 10000
    )

    let regular: CryptoValue
    let priority: CryptoValue

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        let regularFee = try values.decode(Int.self, forKey: .regular)
        let priorityFee = try values.decode(Int.self, forKey: .priority)
        self.init(regular: regularFee, priority: priorityFee)
    }

    init(regular: Int, priority: Int) {
        self.regular = CryptoValue.create(
            minor: regular,
            currency: .stellar
        )
        self.priority = CryptoValue.create(
            minor: priority,
            currency: .stellar
        )
    }
}
