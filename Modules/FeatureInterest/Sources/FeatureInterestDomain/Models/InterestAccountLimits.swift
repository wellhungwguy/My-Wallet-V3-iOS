// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import MoneyKit
import PlatformKit

public struct InterestAccountLimits: Equatable {

    // MARK: - Public Properties

    public let interestLockupDuration: Double
    public let cryptoCurrency: CryptoCurrency
    public let nextInterestPayment: Date
    public let minDepositAmount: FiatValue
    public let maxWithdrawalAmount: FiatValue

    // MARK: - Init

    public init(
        interestLockupDuration: Double,
        cryptoCurrency: CryptoCurrency,
        nextInterestPayment: Date,
        minDepositAmount: FiatValue,
        maxWithdrawalAmount: FiatValue
    ) {
        self.interestLockupDuration = interestLockupDuration
        self.cryptoCurrency = cryptoCurrency
        self.nextInterestPayment = nextInterestPayment
        self.minDepositAmount = minDepositAmount
        self.maxWithdrawalAmount = maxWithdrawalAmount
    }

    public init(
        _ response: InterestLimits,
        cryptoCurrency: CryptoCurrency
    ) {
        self.interestLockupDuration = response.lockUpDuration
        self.cryptoCurrency = cryptoCurrency
        self.nextInterestPayment = Date()
        self.minDepositAmount = response.minDepositAmount
        self.maxWithdrawalAmount = response.maxWithdrawalAmount
    }
}

extension InterestAccountLimits {

    public static func == (
        lhs: InterestAccountLimits,
        rhs: InterestAccountLimits
    ) -> Bool {
        lhs.cryptoCurrency == rhs.cryptoCurrency &&
            lhs.interestLockupDuration == rhs.interestLockupDuration &&
            lhs.maxWithdrawalAmount == rhs.maxWithdrawalAmount &&
            lhs.minDepositAmount == rhs.minDepositAmount &&
            lhs.nextInterestPayment == rhs.nextInterestPayment
    }
}

extension InterestAccountLimits {
    public var lockupDescription: String {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.day]
        formatter.unitsStyle = .short
        // NOTE: `lockUpDuration` is in seconds. Staging returns `600` seconds.
        // So in Staging the value will show as `O Days`
        return formatter.string(from: TimeInterval(interestLockupDuration))?.capitalized ?? ""
    }
}
