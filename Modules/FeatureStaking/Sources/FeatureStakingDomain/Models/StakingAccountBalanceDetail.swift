// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation
import MoneyKit

public struct StakingAccountBalanceDetail: Equatable {
    public let balance: String?
    public let pendingDeposit: String?
    public let pendingWithdrawal: String?
    public let totalRewards: String?
    public let pendingRewards: String?
    public let bondingDeposits: String?
    public let unbondingWithdrawals: String?
    public let locked: String?
    public let mainBalanceToDisplay: String?
    private let currencyCode: String?

    public init(
        balance: String?,
        pendingDeposit: String?,
        pendingWithdrawal: String?,
        totalRewards: String?,
        pendingRewards: String?,
        bondingDeposits: String?,
        unbondingWithdrawals: String?,
        locked: String?,
        mainBalanceToDisplay: String?,
        code: String?
    ) {
        self.balance = balance
        self.pendingDeposit = pendingDeposit
        self.pendingWithdrawal = pendingWithdrawal
        self.totalRewards = totalRewards
        self.pendingRewards = pendingRewards
        self.bondingDeposits = bondingDeposits
        self.unbondingWithdrawals = unbondingWithdrawals
        self.locked = locked
        self.mainBalanceToDisplay = mainBalanceToDisplay
        self.currencyCode = code
    }
}

extension StakingAccountBalanceDetail {
    public var currencyType: CurrencyType? {
        guard let code = currencyCode else {
            return nil
        }
        guard let currencyType = try? CurrencyType(code: code) else {
            return nil
        }
        return currencyType
    }

    public var withdrawableBalance: MoneyValue? {
        guard let currency = currencyType else { return nil }
        guard let balance = moneyBalance else { return nil }
        guard let locked = lockedBalance else { return nil }
        let available = try? balance - locked
        return available ?? .zero(currency: currency)
    }

    public var lockedBalance: MoneyValue? {
        guard let currency = currencyType else { return nil }
        return MoneyValue.create(minor: locked ?? "0", currency: currency)
    }

    public var moneyBalance: MoneyValue? {
        guard let currency = currencyType else { return nil }
        return MoneyValue.create(minor: balance ?? "0", currency: currency)
    }

    public var moneyPendingRewards: MoneyValue? {
        guard let currency = currencyType else { return nil }
        return MoneyValue.create(minor: pendingRewards ?? "0", currency: currency)
    }

    public var moneyTotalRewards: MoneyValue? {
        guard let currency = currencyType else { return nil }
        return MoneyValue.create(minor: totalRewards ?? "0", currency: currency)
    }

    public var moneyPendingWithdrawal: MoneyValue? {
        guard let currency = currencyType else { return nil }
        return MoneyValue.create(minor: pendingWithdrawal ?? "0", currency: currency)
    }

    public var moneyPendingDeposit: MoneyValue? {
        guard let currency = currencyType else { return nil }
        return MoneyValue.create(minor: pendingDeposit ?? "0", currency: currency)
    }

    public var moneyMainBalanceToDisplay: MoneyValue? {
        guard let currency = currencyType else { return nil }
        return MoneyValue.create(minor: mainBalanceToDisplay ?? "0", currency: currency)
    }
}
