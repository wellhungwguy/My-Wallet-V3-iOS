// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import MoneyKit
import PlatformKit

public struct InterestLimits: Decodable {

    public let currency: FiatCurrency
    public let lockUpDuration: Double
    public let maxWithdrawalAmount: FiatValue
    public let minDepositAmount: FiatValue

    private enum CodingKeys: String, CodingKey {
        case currency
        case lockUpDuration
        case maxWithdrawalAmount
        case minDepositAmount
    }

    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)

        let currencyValue = try values.decode(String.self, forKey: .currency)
        self.currency = FiatCurrency(code: currencyValue) ?? .USD
        self.lockUpDuration = try values.decode(Double.self, forKey: .lockUpDuration)
        let withdrawal = try values.decode(String.self, forKey: .maxWithdrawalAmount)
        let deposit = try values.decode(String.self, forKey: .minDepositAmount)
        let zero: FiatValue = .zero(currency: currency)
        self.maxWithdrawalAmount = FiatValue.create(minor: withdrawal, currency: currency) ?? zero
        self.minDepositAmount = FiatValue.create(minor: deposit, currency: currency) ?? zero
    }
}

extension InterestLimits {
    public var lockupDescription: String {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.day]
        formatter.unitsStyle = .short
        // NOTE: `lockUpDuration` is in seconds. Staging returns `Two Hours`.
        // So in Staging the value will show as `O Days`
        return formatter.string(from: TimeInterval(lockUpDuration))?.capitalized ?? ""
    }
}
