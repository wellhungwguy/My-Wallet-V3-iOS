// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import MoneyKit
import PlatformKit
import ToolKit

public struct InterestAccountRate {
    public let cryptoCurrency: CryptoCurrency
    public let rate: Double

    public init(
        currencyCode: String,
        rate: Double
    ) {
        guard let crypto = CryptoCurrency(code: currencyCode) else {
            unimplemented("This currency type is not supported")
        }
        self.cryptoCurrency = crypto
        self.rate = rate
    }
}

extension InterestAccountRate: Equatable {

    public static func == (
        lhs: InterestAccountRate,
        rhs: InterestAccountRate
    ) -> Bool {
        lhs.cryptoCurrency == rhs.cryptoCurrency &&
            lhs.rate == rhs.rate
    }
}
