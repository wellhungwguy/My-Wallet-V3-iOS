// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import MoneyKit
import PlatformKit
import ToolKit

public struct InterestAccountBalanceDetails: Equatable {
    public let balance: String?
    public let locked: String?
    public let pendingInterest: String?
    public let totalInterest: String?
    public let pendingWithdrawal: String?
    public let pendingDeposit: String?
    public let mainBalanceToDisplay: String?

    private let currencyCode: String?

    public init(
        balance: String? = nil,
        pendingInterest: String? = nil,
        locked: String? = nil,
        totalInterest: String? = nil,
        pendingWithdrawal: String? = nil,
        pendingDeposit: String? = nil,
        mainBalanceToDisplay: String? = nil,
        code: String? = nil
    ) {
        self.balance = balance
        self.pendingDeposit = pendingDeposit
        self.locked = locked
        self.pendingInterest = pendingInterest
        self.totalInterest = totalInterest
        self.pendingWithdrawal = pendingWithdrawal
        self.mainBalanceToDisplay = mainBalanceToDisplay
        self.currencyCode = code
    }
}

extension InterestAccountBalanceDetails {
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

    public var moneyPendingInterest: MoneyValue? {
        guard let currency = currencyType else { return nil }
        return MoneyValue.create(minor: pendingInterest ?? "0", currency: currency)
    }

    public var moneyTotalInterest: MoneyValue? {
        guard let currency = currencyType else { return nil }
        return MoneyValue.create(minor: totalInterest ?? "0", currency: currency)
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
