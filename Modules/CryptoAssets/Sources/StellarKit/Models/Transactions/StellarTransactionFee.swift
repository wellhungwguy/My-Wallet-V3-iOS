// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BigInt
import MoneyKit
import PlatformKit

struct StellarTransactionFee: TransactionFee, Decodable {

    enum CodingKeys: String, CodingKey {
        case regular
        case priority
        case limits
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
        regular = CryptoValue(amount: BigInt(regularFee), currency: .stellar)
        priority = CryptoValue(amount: BigInt(priorityFee), currency: .stellar)
    }

    init(regular: Int, priority: Int) {
        self.regular = CryptoValue(amount: BigInt(regular), currency: .stellar)
        self.priority = CryptoValue(amount: BigInt(priority), currency: .stellar)
    }
}
